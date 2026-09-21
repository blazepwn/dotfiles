#!/usr/bin/env bash
set -euo pipefail

REPO=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
ACTION=${1:-help}
APPLY=false
if [[ ${2:-} == --apply && $# == 2 ]]; then
    APPLY=true
elif (( $# > 1 )); then
    printf 'Usage: %s ACTION [--apply]\n' "$0" >&2
    exit 2
fi

die() { printf '%s\n' "$*" >&2; exit 1; }
confirm() {
    local answer
    printf '\n%s\n' "$*"
    read -r -p 'Escribe SI para continuar: ' answer || die 'Cancelado.'
    [[ $answer == SI ]] || die 'Cancelado.'
}
require_arch() {
    [[ -r /etc/os-release ]] || die 'No se encuentra os-release.'
    # shellcheck disable=SC1091
    source /etc/os-release
    [[ ${ID:-} == arch ]] || die 'Este script está diseñado para Arch Linux.'
    command -v pacman >/dev/null || die 'Falta pacman.'
    (( EUID != 0 )) || die 'Ejecuta como usuario normal; sudo se usa por operación.'
}
install_root_file() {
    local source=$1 target=$2 backup
    confirm "Instalar $source en $target, conservando backup del archivo previo."
    sudo -v
    if sudo test -f "$target" && sudo cmp -s "$source" "$target"; then
        printf 'Sin cambios: %s\n' "$target"
        return
    fi
    sudo test ! -L "$target" || die "Revisa el enlace root antes de reemplazar: $target"
    sudo test ! -d "$target" || die "El destino root es un directorio: $target"
    sudo install -d -m 0755 /var/backups
    backup=$(sudo mktemp -d /var/backups/dotfiles.XXXXXXXX)
    if sudo test -e "$target"; then
        sudo cp -a --parents -- "$target" "$backup/"
    fi
    sudo install -D -o root -g root -m 0644 -- "$source" "$target"
    printf 'Backup root: %s\n' "$backup"
}

case "$ACTION" in
    help|-h|--help)
        cat <<'EOF'
Uso: scripts/install.sh ACCIÓN [--apply]
Sin --apply solo muestra el plan. Ejecutar como usuario normal.

packages  Paquetes oficiales seleccionados (actualización completa con pacman).
aur       Paquetes AUR seleccionados; requiere yay ya instalado.
assets    Iconos, Colloid-Dark, fuentes y wallpapers; copia con backup.
configs   Configuraciones de usuario; copia con backup, requiere cerrar Hyprland.
system    Drop-in de tapa (batería = APAGADO), plugin zsh-sudo y zram; confirma cada uno.
services  Habilitar GDM, NetworkManager, Bluetooth, PPD y sockets de audio.

Ambxst, Powerlevel10k y la política ASUS se preparan según README.md.
No hay opción --all. No se particiona, reinicia ni cambia la GPU.
EOF
        exit 0 ;;
    packages|aur|assets|configs|system|services) require_arch ;;
    *) die "Acción desconocida: $ACTION" ;;
esac

case "$ACTION" in
    packages|aur)
        lists=()
        if [[ $ACTION == aur ]]; then
            lists=("$REPO/packages/aur.txt")
        else
            for group in base desktop hyprland asus terminal fonts-theme utilities ambxst apps; do
                lists+=("$REPO/packages/$group.txt")
            done
        fi
        for list in "${lists[@]}"; do
            [[ -r $list ]] || die "Falta la lista de paquetes: $list"
        done
        mapfile -t packages < <(cat -- "${lists[@]}" | sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d' | sort -u)
        (( ${#packages[@]} )) || die 'Lista vacía.'
        printf '%s\n' "${packages[@]}"
        $APPLY || exit 0
        if [[ $ACTION == aur ]]; then
            command -v yay >/dev/null || die 'Instala/revisa yay manualmente según README.'
            confirm 'Revisar e instalar los paquetes AUR listados mediante yay.'
            yay -S --needed "${packages[@]}"
        else
            confirm 'Actualizar Arch e instalar los paquetes oficiales listados con sudo pacman -Syu.'
            sudo pacman -Syu --needed "${packages[@]}"
        fi ;;
    assets|configs)
        command -v python >/dev/null || die 'Falta python; instala primero packages.'
        # El helper comparte estas comprobaciones con su invocación directa.
        flags=()
        $APPLY && flags+=(--apply)
        python "$REPO/scripts/restore.py" "$ACTION" "${flags[@]}"
        ;;
    system)
        printf '%s\n' 'Plan: /etc/systemd/logind.conf.d/20-lid.conf, /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh, /etc/systemd/zram-generator.conf'
        printf '%s\n' 'La tapa en batería causará APAGADO completo; dock/varios monitores conservan ignore. AC lo gestiona Hyprland.'
        $APPLY || exit 0
        install_root_file "$REPO/system/etc/systemd/logind.conf.d/20-lid.conf" /etc/systemd/logind.conf.d/20-lid.conf
        install_root_file "$REPO/vendor/zsh-sudo/sudo.plugin.zsh" /usr/share/zsh/plugins/zsh-sudo/sudo.plugin.zsh
        install_root_file "$REPO/system/etc/systemd/zram-generator.conf" /etc/systemd/zram-generator.conf
        printf '%s\n' 'No se reinició logind. Aplicar en el próximo reboot manual.' ;;
    services)
        printf '%s\n' 'Plan: enable GDM, NetworkManager, bluetooth, power-profiles-daemon; audio por sockets y WirePlumber.'
        $APPLY || exit 0
        confirm 'Habilitar esos servicios para próximos inicios (sin reiniciar la sesión).'
        sudo systemctl enable gdm.service NetworkManager.service bluetooth.service power-profiles-daemon.service
        systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service
        printf '%s\n' 'asusd y portales: activación del paquete. rtkit: D-Bus. hypridle: startup.lua.' ;;
esac
