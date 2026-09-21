-- =========================
-- Laptop Lid
-- =========================

-- La tapa tiene un único responsable en Hyprland: lid-power.sh.
-- Retiro tanto la acción genérica como las acciones DPMS de Ambxst.
hl.unbind("switch:Lid Switch")
hl.unbind("switch:on:Lid Switch")
hl.unbind("switch:off:Lid Switch")

-- Cerrar tapa
hl.bind(
    "switch:on:Lid Switch",
    hl.dsp.exec_cmd(
        "sh -lc '$HOME/.local/bin/lid-power.sh close'"
    ),
    { locked = true }
)

-- Abrir tapa
hl.bind(
    "switch:off:Lid Switch",
    hl.dsp.exec_cmd(
        "sh -lc '$HOME/.local/bin/lid-power.sh open'"
    ),
    { locked = true }
)
