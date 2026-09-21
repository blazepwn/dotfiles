-- =========================
-- Input
-- =========================

hl.config({
    input = {
        -- Teclado
        repeat_rate = 30,
        repeat_delay = 400,

        -- Mouse/focus
        follow_mouse = 1,
        sensitivity = 0.0,

        -- Touchpad
        touchpad = {
            tap_to_click = true,
            tap_and_drag = true,
            disable_while_typing = true,
            natural_scroll = true,
            scroll_factor = 1.0,
            clickfinger_behavior = true,
        },
    },
})
