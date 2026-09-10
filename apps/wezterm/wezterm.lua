local wezterm = require "wezterm"
local mux = wezterm.mux

-- WSL domains only exist on Windows, so this is a no-op on Linux/macOS.
local wsl_domains = wezterm.default_wsl_domains()

wezterm.on("gui-startup", function(cmd)
  local _, _, window = mux.spawn_window {
    domain = cmd and cmd.domain or nil,
  }

  window:gui_window():maximize()
end)

local config = {}
if wezterm.config_builder then config = wezterm.config_builder() end

-- One Dark palette shared with Alacritty and Kitty.
config.color_schemes = {
  ["One Dark"] = {
    ansi = { "#1e2127", "#e06c75", "#98c379", "#d19a66", "#61afef", "#c678dd", "#56b6c2", "#828791" },
    brights = { "#5c6370", "#e06c75", "#98c379", "#d19a66", "#61afef", "#c678dd", "#56b6c2", "#e6efff" },
    background = "#23272E",
    foreground = "#abb2bf",
    cursor_bg = "#abb2bf",
    cursor_fg = "#23272E",
    cursor_border = "#abb2bf",
    selection_bg = "#3e4451",
    selection_fg = "#e6efff",
    scrollbar_thumb = "#3e4451",
    split = "#5c6370",
  },
}

config.color_scheme = "Noctalia"

-- Fallback GPU: WebGpu (Vulkan) est incompatible wayland sur ce système (cf. obsidian vulkan error)
-- OpenGL est plus stable sous niri 26.04 + mesa. Gardé explicite pour wezterm 20240203.
config.front_end = "OpenGL"
config.enable_wayland = true

config.font = wezterm.font("Maple Mono")
config.font_size = 13
config.scrollback_lines = 100000
config.term = "xterm-256color"

-- WezTerm has no cursor trail; use its closest native animated cursor.
config.default_cursor_style = "BlinkingBlock"
config.cursor_blink_rate = 500
config.cursor_blink_ease_in = "EaseInOut"
config.cursor_blink_ease_out = "EaseInOut"
config.animation_fps = 60

config.window_decorations = "NONE"
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

config.keys = {
  {
    key = 'c',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.CopyTo 'Clipboard',
  },
  {
    key = 'v',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.PasteFrom 'Clipboard',
  },
  {
    key = 'n',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ToggleFullScreen,
  },
}

config.enable_tab_bar = false

-- Prefer the Ubuntu WSL distro when a WSL domain is available.
for _, dom in ipairs(wsl_domains) do
  if dom.name == 'WSL:Ubuntu' then
    config.default_domain = 'WSL:Ubuntu'
  end
end

return config
