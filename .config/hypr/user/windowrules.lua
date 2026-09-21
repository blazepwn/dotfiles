-- =========================
-- No initial focus
-- =========================

local no_focus_classes = {
    [[^(org\.telegram\.desktop)$]],
    [[^(elecwhat)$]],
    [[^(discord|discord-canary|Discord)$]],
    [[^(rog-control-center|RogControlCenter)$]],
}

for _, class in ipairs(no_focus_classes) do
    hl.window_rule({
        match = { class = class },
        no_initial_focus = true,
    })
end


-- =========================
-- Floating windows
-- =========================

local float_classes = {
    [[^(Rofi)$]],
    [[^(org\.kde\.polkit-kde-authentication-agent-1|hyprpolkitagent)$]],
    [[^(org\.gnome\.Calculator)$]],
    [[^(org\.gnome\.Nautilus|nautilus)$]],
    [[^(eww)$]],
    [[^(pavucontrol|org\.pulseaudio\.pavucontrol)$]],
    [[^(nm-connection-editor)$]],
    [[^(blueberry\.py)$]],
    [[^(blueman-manager)$]],
    [[^(org\.gnome\.Settings)$]],
    [[^(org\.gnome\.design\.Palette)$]],
    [[^(xdg-desktop-portal|xdg-desktop-portal-gnome)$]],
    [[^(transmission-gtk)$]],
    [[^(org\.telegram\.desktop)$]],
    [[^(rog-control-center)$]],
    [[^(discord)$]],
    [[^(elecwhat)$]],
}

for _, class in ipairs(float_classes) do
    hl.window_rule({
        match = { class = class },
        float = true,
    })
end


-- =========================
-- Floating by title
-- =========================

local float_titles = {
    [[^(Color Picker)$]],
    [[^(Network)$]],
    [[^(web\.whatsapp\.com_/)$]],
}

for _, title in ipairs(float_titles) do
    hl.window_rule({
        match = { title = title },
        float = true,
    })
end


-- =========================
-- Floating sizes
-- =========================

local size_rules = {
    {
        class = [[^(org\.gnome\.Nautilus|nautilus)$]],
        size = { 1400, 900 },
    },
    {
        class = [[^(rog-control-center)$]],
        size = { 1400, 900 },
    },
    {
        class = [[^(discord)$]],
        size = { 2200, 1400 },
    },
    {
        title = [[^(web\.whatsapp\.com_/)$]],
        size = { 1100, 770 },
    },
    {
        class = [[^(elecwhat)$]],
        size = { 1800, 1200 },
    },
    {
        class = [[^(org\.telegram\.desktop)$]],
        size = { 2200, 1400 },
    },
    {
        class = [[^(blueman-manager)$]],
        size = { 600, 400 },
    },
}

for _, rule in ipairs(size_rules) do
    local match = {}

    if rule.class then
        match.class = rule.class
    end

    if rule.title then
        match.title = rule.title
    end

    hl.window_rule({
        match = match,
        size = rule.size,
    })
end


-- =========================
-- Workspace assignments
-- =========================

local workspace_rules = {
    { class = [[^(code)$]], workspace = "3" },
    { class = [[^(org\.telegram\.desktop)$]], workspace = "7" },
    { class = [[^(Vmware|vmware)$]], workspace = "4" },
    { class = [[^(chromium)$]], workspace = "2" },
    { class = [[^(kitty)$]], workspace = "1" },
    { class = [[^(Brave-browser|brave-origin-nightly|brave-browser|brave)$]], workspace = "2" },
    { class = [[^(firefox)$]], workspace = "2" },
    { class = [[^(obsidian)$]], workspace = "4" },
    { class = [[^(burp-StartBurp|burpsuite|BurpSuite)$]], workspace = "3" },
    { class = [[^(discord)$]], workspace = "6" },
    { class = [[^(Spotify|spotify)$]], workspace = "5" },
}

for _, rule in ipairs(workspace_rules) do
    hl.window_rule({
        match = { class = rule.class },
        workspace = rule.workspace,
    })
end
