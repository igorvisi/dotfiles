hl.monitor({
    output = "eDP-1",
    mode = "1920x1200@60",
    position = "1536x0",
    scale = "1.3",
})
hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1080@60",
    position = "0x0",
    scale = "1.25",
})
hl.monitor({
    output = "DP-1",
    mode = "1920x1080@60",
    position = "3072x0",
    scale = "1",
})


local terminal = "kitty"
local fileManager = "nautilus"
local menu = "walker"

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 20,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 12,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
    animations = {
        enabled = true,
    },
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

hl.config({
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo = false,
    },
})

hl.config({
    input = {
        kb_layout = "fr",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

local mainMod = "SUPER"

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = 1 }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- Niri-style workspace stepping (slot by slot, clamped 1..10, no wrap)
local function stepWorkspace(delta, move)
    local cur = hl.get_active_workspace()
    local id = cur and cur.id or 1
    if id < 1 then id = 1 end
    id = math.min(10, math.max(1, id + delta))
    if move then
        hl.dispatch(hl.dsp.window.move({ workspace = id }))
    else
        hl.dispatch(hl.dsp.focus({ workspace = id }))
    end
end

hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + CTRL + H", hl.dsp.window.move({ monitor = "l" }))
hl.bind("SUPER + CTRL + J", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + CTRL + K", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + CTRL + L", hl.dsp.window.move({ monitor = "r" }))
hl.bind("SUPER + CTRL + left", hl.dsp.window.move({ monitor = "l" }))
hl.bind("SUPER + CTRL + right", hl.dsp.window.move({ monitor = "r" }))
hl.bind("SUPER + CTRL + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + CTRL + down", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + SHIFT + CTRL + H", hl.dsp.window.move({ monitor = "l" }))
hl.bind("SUPER + SHIFT + CTRL + J", hl.dsp.window.move({ monitor = "d" }))
hl.bind("SUPER + SHIFT + CTRL + K", hl.dsp.window.move({ monitor = "u" }))
hl.bind("SUPER + SHIFT + CTRL + L", hl.dsp.window.move({ monitor = "r" }))
hl.bind("SUPER + SHIFT + CTRL + left", hl.dsp.window.move({ monitor = "l" }))
hl.bind("SUPER + SHIFT + CTRL + right", hl.dsp.window.move({ monitor = "r" }))
hl.bind("SUPER + SHIFT + CTRL + up", hl.dsp.window.move({ monitor = "u" }))
hl.bind("SUPER + SHIFT + CTRL + down", hl.dsp.window.move({ monitor = "d" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

for i = 1, 10 do
    local code = 9 + i
    hl.bind(mainMod .. " + code:" .. code, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + code:" .. code, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + ampersand", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + eacute", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + quotedbl", hl.dsp.focus({ workspace = 3 }))
for i = 1, 9 do
    local code = 9 + i
    hl.bind(mainMod .. " + CTRL + code:" .. code, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + ALT + U", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + ALT + I", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + ALT + O", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + ALT + P", hl.dsp.window.move({ workspace = 4 }))

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region -o ~/Images/Screenshots"))
hl.bind("SUPER + U", function() stepWorkspace(1, false) end)
hl.bind("SUPER + I", function() stepWorkspace(-1, false) end)
hl.bind("SUPER + Page_Down", function() stepWorkspace(1, false) end)
hl.bind("SUPER + Page_Up", function() stepWorkspace(-1, false) end)
hl.bind("SUPER + CTRL + U", function() stepWorkspace(1, true) end)
hl.bind("SUPER + CTRL + I", function() stepWorkspace(-1, true) end)
hl.bind("SUPER + CTRL + Page_Down", function() stepWorkspace(1, true) end)
hl.bind("SUPER + CTRL + Page_Up", function() stepWorkspace(-1, true) end)
hl.bind("SUPER + ALT + left", function() stepWorkspace(-1, true) end)
hl.bind("SUPER + ALT + right", function() stepWorkspace(1, true) end)

hl.bind(mainMod .. " + mouse_down", function() stepWorkspace(1, false) end)
hl.bind(mainMod .. " + mouse_up", function() stepWorkspace(-1, false) end)
hl.bind(mainMod .. " + CTRL + mouse_down", function() stepWorkspace(1, true) end)
hl.bind(mainMod .. " + CTRL + mouse_up", function() stepWorkspace(-1, true) end)

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

hl.bind("CTRL + ALT + SPACE", hl.dsp.exec_cmd("handy --toggle-transcription"))

hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal .. " $HOME/.local/bin/herdr"))
hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus"))
hl.bind("SUPER + Space", hl.dsp.exec_cmd("walker"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("walker -m clipboard"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("noctalia msg session lock"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + O", hl.dsp.exec_cmd("walker"))
hl.bind("SUPER + H", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + SHIFT + H", hl.dsp.focus({ monitor = "l" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.focus({ monitor = "d" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.focus({ monitor = "u" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.focus({ monitor = "r" }))
hl.bind("SUPER + SHIFT + F", hl.dsp.window.fullscreen({ mode = 0 }))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m output -o ~/Images/Screenshots"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region -o ~/Images/Screenshots"))
hl.bind("ALT + Print", hl.dsp.exec_cmd("hyprshot -m window -o ~/Images/Screenshots"))

local suppressMaximizeRule = hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({ name = "niri-1-terminal", match = { class = "kitty" }, workspace = "1" })
hl.window_rule({ name = "niri-5-code", match = { class = "^dev\\.zed" }, workspace = "5" })
hl.window_rule({ name = "niri-6-music-spotify", match = { class = "^spotify$" }, workspace = "6" })
hl.window_rule({ name = "niri-6-music-vlc", match = { class = "^vlc$" }, workspace = "6" })
hl.window_rule({ name = "niri-6-music-mpv", match = { class = "(?i)^mpv$" }, workspace = "6" })
hl.window_rule({ name = "niri-2-browse-brave", match = { class = "(?i)^(brave-browser|brave|com\\.brave\\.Browser)$" }, workspace = "2" })
hl.window_rule({ name = "niri-2-browse-firefox", match = { class = "^(firefox|org\\.mozilla\\.firefox)$" }, workspace = "2" })
hl.window_rule({ name = "niri-2-browse-chrome", match = { class = "^(google-chrome|com\\.google\\.Chrome|chromium.*|helium.*)$" }, workspace = "2" })
hl.window_rule({ name = "niri-2-browse-obsidian", match = { class = "(?i)obsidian" }, workspace = "2" })
hl.window_rule({ name = "niri-2-browse-fbreader", match = { class = "^com\\.fbreader$" }, workspace = "2" })
hl.window_rule({ name = "niri-3-ai", match = { class = "(?i)^(chatgpt|com\\.openai\\.chatgpt|ai\\.opencode\\.desktop|hermes|com\\.hermes\\.desktop)$" }, workspace = "3" })
hl.window_rule({ name = "niri-4-chat", match = { class = "(?i)^(discord|slack|io\\.element\\.element|org\\.telegram\\.desktop|telegramdesktop|signal|org\\.gnome\\.thunderbird)$" }, workspace = "4" })

hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("walker --gapplication-service")
    hl.exec_cmd("$HOME/dotfiles/script/cliphist-watch.sh")
end)

hl.on("window.open", function(win)
    local ws = win.workspace
    if ws then
        hl.dispatch(hl.dsp.focus({ workspace = ws.id }))
    end
end)
hl.bind("SUPER + A", hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + ALT + Delete", hl.dsp.exit())

hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = "20 monitor_h-120",
    float = true,
})
