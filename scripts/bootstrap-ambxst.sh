#!/usr/bin/env bash
set -euo pipefail
REPO=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
if (( $# == 0 )); then
    printf '%s\n' 'Plan: desde una TTY local sin sesión gráfica, iniciar Hyprland temporal con Ambxst para que genere su integración.'
    printf '%s\n' 'Primero instala componentes manuales y restaura assets/system/configs. No crea ni edita Lua generado.'
    exit 0
fi
[[ $# == 1 && $1 == --apply ]] || { printf 'Uso: %s [--apply]\n' "$0" >&2; exit 2; }
[[ $EUID != 0 ]] || { echo 'Ejecuta como usuario, sin sudo.' >&2; exit 1; }
source /etc/os-release
[[ $ID == arch ]] || { echo 'Se requiere Arch Linux.' >&2; exit 1; }
for cmd in pacman Hyprland ambxst axctl qs kitty python luac; do
    command -v "$cmd" >/dev/null || { echo "Falta $cmd" >&2; exit 1; }
done
[[ -z ${WAYLAND_DISPLAY:-} && -z ${DISPLAY:-} && -t 0 ]] || {
    echo 'Cierra la sesión gráfica y ejecuta desde una TTY local.' >&2; exit 1;
}
for proc in Hyprland ambxst qs quickshell; do
    if pgrep -u "$(id -u)" -x "$proc" >/dev/null; then
        echo "Sigue activo $proc; no iniciar otra instancia." >&2; exit 1
    fi
done
python "$REPO/scripts/restore.py" configs --check
[[ -r $HOME/.config/hypr/hyprland.lua && -r $HOME/.config/ambxst/config/system.json ]] || {
    echo 'Restaura configs antes del bootstrap.' >&2; exit 1;
}
python -c 'import json,pathlib; p=pathlib.Path.home()/".config/ambxst/config/system.json"; assert json.loads(p.read_text())["idle"]["listeners"] == [], "Restaura primero los listeners vacíos"'
if [[ -s $HOME/.local/share/ambxst/hyprland.lua ]]; then
    echo 'La integración ya existe; no hace falta un bootstrap.'
    exit 0
fi
printf '%s\n' 'En Kitty: comprueba test -s "$HOME/.local/share/ambxst/hyprland.lua" y luac -p sobre ese archivo.'
printf '%s\n' 'Después ejecuta ambxst quit y sal con hyprctl dispatch '\''hl.dsp.exit()'\''; entra normalmente por GDM.'
Hyprland --config "$REPO/scripts/bootstrap-hyprland.lua"
[[ -s $HOME/.local/share/ambxst/hyprland.lua ]] || {
    echo 'No se generó la integración. Revisa el arranque de Ambxst/axctl; no fabriques el archivo.' >&2; exit 1;
}
luac -p "$HOME/.local/share/ambxst/hyprland.lua"
echo 'Integración generada. Entra en la sesión normal Hyprland desde GDM.'
