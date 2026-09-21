#!/bin/sh

is_on_ac() {
    for supply in /sys/class/power_supply/*; do
        [ -r "$supply/online" ] || continue

        if [ "$(cat "$supply/online")" = "1" ]; then
            return 0
        fi
    done

    return 1
}

case "$1" in
    close)
        # Solo actuar aquí si estamos conectados al cargador.
        # En batería, systemd-logind hará el poweroff.
        if is_on_ac; then
            ambxst lock
            sleep 0.5
            hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'
        fi
        ;;

    open)
        # Siempre intentar encender la pantalla al abrir.
        hyprctl dispatch 'hl.dsp.dpms({ action = "enable" })'
        ;;
esac
