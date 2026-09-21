-- Sesión temporal de primer arranque. No importa el Lua generado de Ambxst.
-- El daemon y la shell lo generarán; después salgo y entro por GDM normalmente.
hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"))
hl.on("hyprland.start", function()
    hl.exec_cmd("ambxst")
    hl.exec_cmd("kitty")
end)
