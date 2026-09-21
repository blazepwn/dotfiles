#!/usr/bin/env bash
# Baseline UFW de esta laptop. Nunca resetear reglas ni ejecutar desde SSH.
set -euo pipefail
die() { printf '%s\n' "$*" >&2; exit 1; }
if (( $# == 0 )); then
    printf '%s\n' 'Plan UFW: deny incoming, allow outgoing, deny routed, logging low, IPv6 ya habilitado por el paquete.'
    printf '%s\n' 'Solo --apply, desde TTY local, habilita el firewall ahora y el servicio para próximos boots.'
    exit 0
fi
[[ $# == 1 && $1 == --apply ]] || die "Uso: $0 [--apply]"
(( EUID != 0 )) || die 'Ejecuta como usuario normal; sudo se pide por operación.'
source /etc/os-release
[[ $ID == arch ]] || die 'Se requiere Arch Linux.'
command -v ufw >/dev/null || die 'Instala ufw primero.'
command -v pacman >/dev/null || die 'Falta pacman.'
[[ -z ${SSH_CONNECTION:-} && -z ${SSH_CLIENT:-} && -z ${SSH_TTY:-} ]] || die 'No ejecutar desde SSH.'
[[ $(tty) =~ ^/dev/tty[0-9]+$ ]] || die 'Usa una TTY local; no SSH, tmux ni terminal gráfica.'
grep -qx 'IPV6=yes' /etc/default/ufw || die 'IPv6 difiere de la baseline; revisa /etc/default/ufw.'
package_state=$(LC_ALL=C pacman -Qii ufw)
if grep -E '/etc/ufw/(before6?\.rules|after6?\.rules|sysctl\.conf)|/etc/default/ufw' <<< "$package_state" | grep -Fq '[modified]'; then
    die 'Hay políticas o reglas base modificadas; revísalas manualmente antes de aplicar la baseline.'
fi
read -r -p 'Aplicar baseline y habilitar UFW ahora (escribe SI): ' answer
[[ $answer == SI ]] || die 'Cancelado.'
sudo -v
sudo env LC_ALL=C ufw status verbose
added=$(sudo env LC_ALL=C ufw show added)
printf '%s\n' "$added"
if grep -Eq '^[[:space:]]*ufw ' <<< "$added"; then
    die 'Hay reglas de usuario; revisa su intención. Este script no las borra ni cambia políticas debajo de ellas.'
fi
if grep -qx 'ENABLED=yes' /etc/ufw/ufw.conf; then
    printf '%s\n' 'UFW ya está habilitado. Se conserva; contrasta el estado mostrado con docs/firewall.md.'
    exit 0
fi
sudo install -d -m 0755 /var/backups
backup=$(sudo mktemp -d /var/backups/dotfiles-ufw.XXXXXXXX)
sudo cp -a /etc/ufw "$backup/"
sudo cp -a /etc/default/ufw "$backup/default-ufw"
printf 'Backup UFW: %s\n' "$backup"
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default deny routed
sudo ufw logging low
# ufw solicita además su propia confirmación antes de activar las reglas.
sudo ufw enable
sudo systemctl enable ufw.service
sudo ufw status verbose
