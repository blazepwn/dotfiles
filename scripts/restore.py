#!/usr/bin/env python3
"""Copy reviewed dotfiles; default is a read-only plan. No root operations."""
import argparse
import filecmp
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

REPO = Path(__file__).resolve().parent.parent


def entries(group):
    """Only explicit, reviewed paths. Unlisted future files are never copied."""
    pairs = []
    seen = set()
    for name in (REPO / "manifests" / f"{group}.txt").read_text().splitlines():
        if not name or name.startswith("#"):
            continue
        relative = Path(name)
        forbidden = {".ssh", ".gnupg", ".cache", "node_modules", "__pycache__",
                     "keyrings", "cookies", "credentials", "secrets", ".env",
                     "assistant.json", "ai.json", "weather.json"}
        if (relative.is_absolute() or ".." in relative.parts
                or any(part.lower() in forbidden for part in relative.parts)
                or relative.suffix.lower() in {".db", ".sqlite", ".sqlite3", ".sock", ".pipe", ".pem", ".key", ".p12", ".pfx", ".kdbx", ".log"}
                or (group == "configs" and ("history" in relative.name.lower()
                    or relative.name.lower().startswith(("credentials", "secrets", "cookies", ".env"))))):
            raise ValueError(f"Forbidden manifest path: {relative}")
        allowed = ((".icons/", ".themes/", ".fonts/", "Pictures/Wallpapers/")
                   if group == "assets" else
                   tuple(f".config/{p}/" for p in ("hypr", "kitty", "lsd", "gtk-3.0",
                         "gtk-4.0", "nwg-look", "xsettingsd", "ambxst")))
        singles = {".zshrc", ".p10k.zsh", ".local/bin/lid-power.sh", ".local/share/nwg-look/gsettings"}
        if not name.startswith(allowed) and not (group == "configs" and name in singles):
            raise ValueError(f"Unapproved manifest root: {relative}")
        if name in seen:
            raise ValueError(f"Duplicate manifest path: {relative}")
        seen.add(name)
        src = REPO / relative
        if not src.resolve().is_relative_to(REPO):
            raise ValueError(f"Source escapes repository: {relative}")
        if src.is_dir() and not src.is_symlink():
            raise ValueError(f"Manifest must list files, not trees: {relative}")
        target = (Path(".local/share/fonts/dotfiles") / relative.relative_to(".fonts")
                  if name.startswith(".fonts/") else relative)
        pairs.append((src, target))
    if not pairs:
        raise ValueError(f"Empty manifest: {group}")
    return pairs


def preflight(group, home, applying):
    """Shared by the direct CLI and install.sh; fail before any write."""
    import platform
    if os.geteuid() == 0:
        raise ValueError("Run as your desktop user, without sudo")
    if platform.freedesktop_os_release().get("ID") != "arch" or not shutil.which("pacman"):
        raise ValueError("This restore requires Arch Linux and pacman")
    for key, default in (("XDG_CONFIG_HOME", home / ".config"),
                         ("XDG_DATA_HOME", home / ".local/share"),
                         ("XDG_STATE_HOME", home / ".local/state")):
        if os.environ.get(key) and Path(os.environ[key]) != default:
            raise ValueError(f"Nonstandard {key}: review paths before restoring")
    if REPO.is_relative_to(home / ".config"):
        raise ValueError("Keep the clone outside ~/.config")
    if not applying:
        return
    if group == "assets":
        if not shutil.which("fc-cache"):
            raise ValueError("Install fontconfig first")
        return
    for name in ("pgrep", "systemctl", "ambxst", "axctl", "qs", "hypridle", "kitty"):
        if not shutil.which(name):
            raise ValueError(f"Missing prerequisite: {name}")
    result = subprocess.run(["systemctl", "--user", "show", "hypridle.service",
                             "-p", "LoadState", "-p", "ActiveState", "-p", "UnitFileState"],
                            capture_output=True, text=True)
    state = dict(line.split("=", 1) for line in result.stdout.splitlines() if "=" in line)
    if result.returncode and state.get("LoadState") != "not-found":
        raise ValueError("Cannot inspect user systemd; use a local login with a user bus")
    if not state or "LoadState" not in state:
        raise ValueError("Cannot determine hypridle.service state")
    if (state.get("ActiveState") not in ("inactive", "failed", None)
            or state.get("UnitFileState", "").startswith("enabled")):
        raise ValueError("hypridle.service is enabled/active; review it before configs (startup.lua owns hypridle)")
    for process in ("Hyprland", "ambxst", "hypridle"):
        check = subprocess.run(["pgrep", "-u", str(os.getuid()), "-x", process], capture_output=True)
        if check.returncode == 0:
            raise ValueError(f"Close {process} before restoring configs; use GNOME/TTY")
        if check.returncode != 1:
            raise ValueError(f"Cannot check running process: {process}")
    for path in (home / ".powerlevel10k/powerlevel10k.zsh-theme",
                 Path("/usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh"),
                 home / ".themes/Colloid-Dark/gtk-4.0/gtk.css",
                 home / ".local/src/ambxst/shell.qml"):
        if not path.is_file():
            raise ValueError(f"Install manual components/system/assets first: {path}")


def check_parents(home, relative):
    if relative.is_absolute() or ".." in relative.parts:
        raise ValueError(f"Unsafe destination: {relative}")
    parent = home
    for part in relative.parts[:-1]:
        parent /= part
        if parent.is_symlink() or (parent.exists() and not parent.is_dir()):
            raise ValueError(f"Parent must be a real directory: {parent}")


def equal(src, dst):
    if src.is_symlink():
        return dst.is_symlink() and os.readlink(src) == os.readlink(dst)
    return (not dst.is_symlink() and dst.is_file()
            and filecmp.cmp(src, dst, shallow=False)
            and (src.stat().st_mode & 0o777) == (dst.stat().st_mode & 0o777))


def restore(home, pairs, apply=False, retire=()):
    home = home.resolve(strict=True)
    if home == REPO or home.is_relative_to(REPO):
        raise ValueError("The destination must not be the repository")
    changes = []
    # Finish all preflight checks before the first write.
    for src, relative in pairs:
        check_parents(home, relative)
        if not src.exists():
            raise ValueError(f"Missing source / broken link: {src}")
        if src.is_symlink():
            link = Path(os.readlink(src))
            resolved = (home / relative.parent / link).resolve()
            if link.is_absolute() or not resolved.is_relative_to(home):
                raise ValueError(f"Source link escapes HOME: {src}")
        dst = home / relative
        if dst.is_dir() and not dst.is_symlink():
            raise ValueError(f"Directory conflicts with a file: {dst}")
        if not equal(src, dst):
            changes.append((src, relative))
    retired = []
    for relative in retire:
        check_parents(home, relative)
        if os.path.lexists(home / relative):
            retired.append(relative)
    print(f"{'APPLY' if apply else 'PLAN'}: {len(changes)} files, "
          f"{len(retired)} obsolete entrypoints to archive")
    if not apply:
        for _, relative in changes[:50]:
            print(f"  copy {relative}")
        if len(changes) > 50:
            print(f"  … {len(changes) - 50} additional asset files")
        for relative in retired:
            print(f"  archive {relative}")
        return None
    if not changes and not retired:
        print("Already up to date; no backup needed.")
        return None
    backup_relative = Path(".local/state/dotfiles-backups")
    check_parents(home, backup_relative / "placeholder")
    backup_base = home / backup_relative
    backup_base.mkdir(parents=True, exist_ok=True, mode=0o700)
    backup = Path(tempfile.mkdtemp(prefix="restore-", dir=backup_base))
    print(f"Backup: {backup}")
    # A private manifest records both replaced and newly created paths.
    with (backup / "manifest.tsv").open("w") as manifest:
        for relative in retired:
            target = backup / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(home / relative), target)
            manifest.write(f"archived\t{relative}\n")
            manifest.flush()
        for src, relative in changes:
            dst = home / relative
            present = os.path.lexists(dst)
            if present:
                saved = backup / relative
                saved.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(dst, saved, follow_symlinks=False)
            manifest.write(f"{'replaced' if present else 'created'}\t{relative}\n")
            manifest.flush()
            dst.parent.mkdir(parents=True, exist_ok=True)
            fd, name = tempfile.mkstemp(prefix=".dotfiles-", dir=dst.parent)
            os.close(fd)
            temp = Path(name)
            try:
                if src.is_symlink():
                    temp.unlink()
                    temp.symlink_to(os.readlink(src))
                else:
                    shutil.copy2(src, temp)
                os.replace(temp, dst)
            finally:
                if os.path.lexists(temp):
                    temp.unlink()
    return backup


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("group", choices=("configs", "assets"))
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--apply", action="store_true")
    mode.add_argument("--check", action="store_true", help="Run apply preflight without copying")
    args = parser.parse_args()
    home = Path.home()
    retire = (Path(".config/hypr/hyprland.conf"),) if args.group == "configs" else ()
    try:
        preflight(args.group, home, args.apply or args.check)
        restore(home, entries(args.group), args.apply, retire)
        if args.group == "assets" and args.apply:
            subprocess.run(["fc-cache", "-f", str(home / ".local/share/fonts/dotfiles")], check=True)
        if args.group == "configs" and not (home / ".local/share/ambxst/hyprland.lua").is_file():
            print("First run pending: scripts/bootstrap-ambxst.sh --apply from a local TTY after restoring configs")
    except (OSError, ValueError, subprocess.CalledProcessError) as error:
        parser.exit(1, f"Restore stopped: {error}\n")


if __name__ == "__main__":
    main()
