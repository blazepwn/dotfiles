"""Safety checks use temporary directories only, never the live HOME."""
import contextlib
import io
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch
from types import SimpleNamespace

from restore import restore, entries, preflight


class RestoreSafety(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.base = Path(self.temp.name)
        self.home = self.base / "target"
        self.home.mkdir()
        self.src = self.base / "source"
        self.src.write_text("new\n")
        self.silence = contextlib.redirect_stdout(io.StringIO())
        self.silence.__enter__()
        self.addCleanup(self.silence.__exit__, None, None, None)

    def test_dry_run_creates_nothing(self):
        restore(self.home, [(self.src, Path(".config/app/config"))])
        self.assertEqual(list(self.home.iterdir()), [])

    def test_backup_and_idempotence_preserve_unmanaged_files(self):
        dst = self.home / "config"
        dst.write_text("old\n")
        other = self.home / "personal"
        other.write_text("keep\n")
        backup = restore(self.home, [(self.src, Path("config"))], True)
        self.assertEqual((backup / "config").read_text(), "old\n")
        self.assertEqual(dst.read_text(), "new\n")
        self.assertEqual(other.read_text(), "keep\n")
        self.assertIsNone(restore(self.home, [(self.src, Path("config"))], True))

    def test_destination_link_does_not_modify_external_target(self):
        outside = self.base / "outside"
        outside.write_text("private\n")
        dst = self.home / "config"
        dst.symlink_to(outside)
        backup = restore(self.home, [(self.src, Path("config"))], True)
        self.assertTrue((backup / "config").is_symlink())
        self.assertFalse(dst.is_symlink())
        self.assertEqual(outside.read_text(), "private\n")

    def test_parent_symlink_aborts_before_any_copy(self):
        outside = self.base / "external-dir"
        outside.mkdir()
        (self.home / ".config").symlink_to(outside)
        with self.assertRaises(ValueError):
            restore(self.home, [(self.src, Path("first")),
                                (self.src, Path(".config/app"))], True)
        self.assertFalse((self.home / "first").exists())
        self.assertEqual(list(outside.iterdir()), [])

    def test_missing_source_aborts_before_any_copy(self):
        with self.assertRaises(ValueError):
            restore(self.home, [(self.src, Path("first")),
                                (self.base / "missing", Path("second"))], True)
        self.assertEqual(list(self.home.iterdir()), [])

    def test_legacy_entrypoint_is_archived(self):
        old = self.home / "hyprland.conf"
        old.write_text("old syntax\n")
        backup = restore(self.home, [], True, (Path("hyprland.conf"),))
        self.assertFalse(old.exists())
        self.assertEqual((backup / "hyprland.conf").read_text(), "old syntax\n")

    def test_relative_source_link_is_restored(self):
        link = self.base / "link"
        link.symlink_to("source")
        restore(self.home, [(self.src, Path("source")), (link, Path("link"))], True)
        self.assertTrue((self.home / "link").is_symlink())
        self.assertEqual((self.home / "link").read_text(), "new\n")

    def test_future_private_file_is_not_selected(self):
        repo = self.base / "repo"
        (repo / "manifests").mkdir(parents=True)
        (repo / ".config/hypr").mkdir(parents=True)
        (repo / "manifests/configs.txt").write_text(".config/hypr/hyprland.lua\n")
        (repo / ".config/hypr/hyprland.lua").write_text("-- reviewed\n")
        private = repo / ".config/hypr/credentials.json"
        private.write_text('"private, must stay here"')
        with patch("restore.REPO", repo):
            pairs = entries("configs")
        self.assertEqual([str(dst) for _, dst in pairs], [".config/hypr/hyprland.lua"])

    def test_manifest_cannot_import_external_link(self):
        repo = self.base / "repo"
        (repo / "manifests").mkdir(parents=True)
        (repo / "manifests/configs.txt").write_text(".zshrc\n")
        (repo / ".zshrc").symlink_to(self.src)
        with patch("restore.REPO", repo), self.assertRaises(ValueError):
            entries("configs")

    def test_manifest_refuses_explicit_credentials_entry(self):
        repo = self.base / "repo"
        (repo / "manifests").mkdir(parents=True)
        (repo / "manifests/configs.txt").write_text(".config/hypr/credentials.json\n")
        with patch("restore.REPO", repo), self.assertRaisesRegex(ValueError, "Forbidden"):
            entries("configs")

    def test_first_restore_does_not_require_generated_ambxst_lua(self):
        for relative in [".powerlevel10k/powerlevel10k.zsh-theme",
                         ".themes/Colloid-Dark/gtk-4.0/gtk.css", ".local/src/ambxst/shell.qml"]:
            p = self.home / relative
            p.parent.mkdir(parents=True, exist_ok=True)
            p.write_text("fixture")
        original = Path.is_file
        def is_file(path):
            return (str(path) == "/usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh"
                    or original(path))
        status = SimpleNamespace(returncode=0, stdout="LoadState=loaded\nActiveState=inactive\nUnitFileState=disabled\n")
        absent = SimpleNamespace(returncode=1, stdout="")
        with patch("restore.os.geteuid", return_value=1000), \
                patch.dict("os.environ", {}, clear=True), \
                patch("platform.freedesktop_os_release", return_value={"ID": "arch"}), \
                patch("restore.shutil.which", return_value="/usr/bin/present"), \
                patch.object(Path, "is_file", is_file), \
                patch("restore.subprocess.run", side_effect=[status, absent, absent, absent]):
            preflight("configs", self.home, True)
        self.assertFalse((self.home / ".local/share/ambxst/hyprland.lua").exists())

    def test_direct_cli_preflight_rejects_enabled_idle_service(self):
        status = SimpleNamespace(returncode=0, stdout="LoadState=loaded\nActiveState=inactive\nUnitFileState=enabled\n")
        with patch("restore.os.geteuid", return_value=1000), \
                patch.dict("os.environ", {}, clear=True), \
                patch("platform.freedesktop_os_release", return_value={"ID": "arch"}), \
                patch("restore.shutil.which", return_value="/usr/bin/present"), \
                patch("restore.subprocess.run", return_value=status), self.assertRaisesRegex(ValueError, "hypridle.service"):
            preflight("configs", self.home, True)

    def test_direct_cli_preflight_rejects_running_hyprland(self):
        status = SimpleNamespace(returncode=0, stdout="LoadState=loaded\nActiveState=inactive\nUnitFileState=disabled\n")
        running = SimpleNamespace(returncode=0, stdout="1234")
        with patch("restore.os.geteuid", return_value=1000), \
                patch.dict("os.environ", {}, clear=True), \
                patch("platform.freedesktop_os_release", return_value={"ID": "arch"}), \
                patch("restore.shutil.which", return_value="/usr/bin/present"), \
                patch("restore.subprocess.run", side_effect=[status, running]), self.assertRaisesRegex(ValueError, "Close Hyprland"):
            preflight("configs", self.home, True)


if __name__ == "__main__":
    unittest.main()
