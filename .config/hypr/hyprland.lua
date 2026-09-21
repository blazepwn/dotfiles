-- =========================
-- Ambxst
-- =========================

loadfile(os.getenv("HOME") .. "/.local/share/ambxst/hyprland.lua")()

-- =========================
-- User Overrides
-- =========================

require("user.env")
require("user.binds")
require("user.windowrules")
require("user.startup")
require("user.input")
require("user.gestures")
require("user.lid")
