local mainMod = "SUPER"

-- =========================
-- Unbind Ambxst conflicts
-- =========================

local custom_binds = {
    mainMod .. " + Return",
    mainMod .. " + E",
    mainMod .. " + T",
    mainMod .. " + F",
    mainMod .. " + Q",
    mainMod .. " + left",
    mainMod .. " + right",
    mainMod .. " + up",
    mainMod .. " + down",
    mainMod .. " + mouse:272",
    mainMod .. " + mouse:273",
    mainMod .. " + SHIFT + B",
    mainMod .. " + ALT + Down",
    mainMod .. " + ALT + j",
    mainMod .. " + ALT + Up",
    mainMod .. " + ALT + k",
    "XF86AudioRaiseVolume",
    "XF86AudioLowerVolume",
    "XF86AudioMute",
    "XF86AudioMicMute",
    "XF86MonBrightnessUp",
    "XF86MonBrightnessDown",
    "XF86AudioNext",
    "XF86AudioPrev",
    "XF86AudioPlay",
    "XF86AudioPause",
}

for _, bind in ipairs(custom_binds) do
    hl.unbind(bind)
end

-- Ambxst asignaba dos acciones a esta combinación. Dejo solo la barra.
-- Para reiniciar la shell ejecuto `ambxst reload` explícitamente.
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("ambxst toggle bar"))

-- El generador de Ambxst usa exec_cmd("resizeactive ...") en estos cuatro
-- atajos. Los sustituyo aquí sin editar su archivo generado.
for _, key in ipairs({ "Down", "j" }) do
    hl.bind(mainMod .. " + ALT + " .. key,
        hl.dsp.window.resize({ x = 0, y = 50, relative = true }))
end
for _, key in ipairs({ "Up", "k" }) do
    hl.bind(mainMod .. " + ALT + " .. key,
        hl.dsp.window.resize({ x = 0, y = -50, relative = true }))
end

for i = 1, 10 do
    local key = i % 10
    hl.unbind(mainMod .. " + " .. key)
    hl.unbind(mainMod .. " + SHIFT + " .. key)
end


-- =========================
-- Applications
-- =========================

hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus"))


-- =========================
-- Windows
-- =========================

hl.bind(
    mainMod .. " + T",
    hl.dsp.window.float({ action = "toggle" })
)

hl.bind(
    mainMod .. " + Q",
    hl.dsp.window.close()
)

hl.bind(
    mainMod .. " + F",
    hl.dsp.window.fullscreen()
)


-- =========================
-- Focus
-- =========================

hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))


-- =========================
-- Workspaces 1-10
-- =========================

for i = 1, 10 do
    local key = i % 10

    hl.bind(
        mainMod .. " + " .. key,
        hl.dsp.focus({ workspace = i })
    )

    hl.bind(
        mainMod .. " + SHIFT + " .. key,
        hl.dsp.window.move({ workspace = i })
    )
end


-- =========================
-- Mouse
-- =========================

hl.bind(
    mainMod .. " + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true }
)

hl.bind(
    mainMod .. " + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true }
)


-- =========================
-- Audio
-- =========================

hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true }
)

hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true }
)

hl.bind(
    "XF86AudioMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true }
)

hl.bind(
    "XF86AudioMicMute",
    hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true }
)


-- =========================
-- Brightness
-- =========================

hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),
    { locked = true, repeating = true }
)

hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),
    { locked = true, repeating = true }
)


-- =========================
-- Multimedia
-- =========================

hl.bind(
    "XF86AudioNext",
    hl.dsp.exec_cmd("playerctl next"),
    { locked = true }
)

hl.bind(
    "XF86AudioPrev",
    hl.dsp.exec_cmd("playerctl previous"),
    { locked = true }
)

hl.bind(
    "XF86AudioPlay",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true }
)

hl.bind(
    "XF86AudioPause",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true }
)
