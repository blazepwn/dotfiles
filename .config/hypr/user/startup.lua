-- =========================
-- Startup
-- =========================

hl.on("hyprland.start", function()
    hl.exec_cmd("hypridle")
    -- Terminal
    hl.exec_cmd("kitty")

    -- =========================
    -- Applications
    -- =========================

    hl.exec_cmd(
        "sh -lc 'if command -v Telegram >/dev/null 2>&1; then sleep 5; exec Telegram -startintray; fi'",
        { workspace = "7 silent" }
    )

    hl.exec_cmd(
        "sh -lc 'sleep 5; discord-canary --start-minimized'",
        { workspace = "6 silent" }
    )

    hl.exec_cmd(
        "sh -lc 'sleep 5; rog-control-center'",
        { workspace = "9 silent" }
    )

    hl.exec_cmd(
        "sh -lc 'sleep 5; elecwhat'",
        { workspace = "8 silent" }
    )


    -- =========================
    -- GTK
    -- =========================

    hl.exec_cmd("nwg-look -a")


    -- =========================
    -- Polkit
    -- =========================

    hl.exec_cmd(
        [[bash -lc 'for agent in \
/usr/lib/hyprpolkitagent/hyprpolkitagent \
/usr/lib/polkit-kde-authentication-agent-1 \
/usr/libexec/polkit-kde-authentication-agent-1 \
/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
/usr/lib/lxqt-policykit-agent \
/usr/lib/mate-polkit/polkit-mate-authentication-agent-1; \
do [ -x "$agent" ] && exec "$agent"; done; exit 0']]
    )


    -- =========================
    -- Cursor
    -- =========================

    hl.exec_cmd("hyprctl setcursor GoogleDot-Black 24")


    -- =========================
    -- Audio
    -- =========================

    hl.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ 0")


    -- =========================
    -- DBus / Wayland
    -- =========================

    hl.exec_cmd(
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
    )
end)
