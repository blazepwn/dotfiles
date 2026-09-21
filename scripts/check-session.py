#!/usr/bin/env python3
"""Read-only checks. Run inside Hyprland; never dispatches actions."""
from collections import Counter
import json
import os
from pathlib import Path
import re
import subprocess
import sys


def output(*args):
    return subprocess.check_output(args, text=True).strip()


def main():
    failures = []
    errors = output("hyprctl", "configerrors")
    if errors:
        failures.append("Hyprland configerrors: " + errors)
    binds = json.loads(output("hyprctl", "-j", "binds"))
    counts = Counter((b["submap"], b["modmask"], b["key"].lower(), b["keycode"]) for b in binds)
    duplicates = [(key, n) for key, n in counts.items() if n > 1]
    if duplicates:
        failures.append("Bindings duplicados: " + repr(duplicates))
    lid = [b["key"] for b in binds if "Lid Switch" in b["key"]]
    if sorted(lid) != ["switch:off:Lid Switch", "switch:on:Lid Switch"]:
        failures.append("Bindings de tapa inesperados: " + repr(lid))
    home = Path.home()
    idle = json.loads((home / ".config/ambxst/config/system.json").read_text())["idle"]
    if idle["listeners"] != []:
        failures.append("Ambxst tiene listeners de idle habilitados")
    if idle["general"]["lock_cmd"] != "ambxst lock":
        failures.append("El lock_cmd de Ambxst cambió")
    conf = (home / ".config/hypr/hypridle.conf").read_text()
    if re.findall(r"^\s*timeout\s*=\s*(\d+)", conf, re.M) != ["300", "600", "1800"]:
        failures.append("Tiempos de hypridle distintos de 5/10/30")
    result = subprocess.run(["pgrep", "-u", str(os.getuid()), "-x", "hypridle"], capture_output=True, text=True)
    if len(result.stdout.splitlines()) != 1:
        failures.append("Se esperaba un único proceso hypridle")
    state = output("systemctl", "--user", "show", "hypridle.service", "-p", "ActiveState", "-p", "UnitFileState")
    if "UnitFileState=enabled" in state or "ActiveState=active" in state:
        failures.append("hypridle.service también está habilitado/activo")
    targets = output("qs", "ipc", "-p", str(home / ".local/src/ambxst/shell.qml"), "show")
    if "target lockscreen" not in targets:
        failures.append("No se encontró el target IPC lockscreen de Ambxst")
    print("Bindings duplicados:", len(duplicates))
    print("Eventos de tapa:", ", ".join(lid))
    print("Listeners temporizados de Ambxst:", len(idle["listeners"]))
    for failure in failures:
        print("ERROR:", failure)
    if not failures:
        print("OK: configuración cargada, hypridle único y lockscreen disponible. No se probaron acciones físicas.")
    return bool(failures)


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError) as error:
        sys.exit(f"No se pudo verificar la sesión: {error}")
