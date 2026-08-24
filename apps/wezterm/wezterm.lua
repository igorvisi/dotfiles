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

-- Noctalia scheme inline pour compat wezterm 20240203 (qui ignore colors/*.toml)
-- Généré depuis colors/Noctalia.toml ; gardé en Lua + TOML pour les versions récentes
config.color_schemes = {
  ["Noctalia"] = {
    ansi = { "#21252b", "#e27881", "#98c379", "#eac786", "#71b9f4", "#c88bda", "#62bac6", "#c9ccd3" },
    brights = { "#282c34", "#e68991", "#a8cc8e", "#edcf97", "#8dc7f6", "#d3a2e2", "#78c4ce", "#e6e6e6" },
    background = "#21252b",
    foreground = "#e6e6e6",
    cursor_bg = "#78c4ce",
    cursor_fg = "#21252b",
    cursor_border = "#78c4ce",
    selection_bg = "#393e47",
    selection_fg = "#e6e6e6",
    scrollbar_thumb = "#393e47",
    split = "#282c34",
    compose_cursor = "#78c4ce",
    visual_bell = "#21252b",
    indexed = { [16] = "#eac786", [17] = "#78c4ce" },
    tab_bar = {
      background = "#21252b",
      inactive_tab_edge = "#393e47",
      active_tab = { bg_color = "#62bac6", fg_color = "#21252b", intensity = "Normal", italic = false, strikethrough = false, underline = "None" },
      inactive_tab = { bg_color = "#21252b", fg_color = "#e6e6e6", intensity = "Normal", italic = false, strikethrough = false, underline = "None" },
      inactive_tab_hover = { bg_color = "#21252b", fg_color = "#e6e6e6", intensity = "Normal", italic = false, strikethrough = false, underline = "None" },
      new_tab = { bg_color = "#393e47", fg_color = "#e6e6e6", intensity = "Normal", italic = false, strikethrough = false, underline = "None" },
      new_tab_hover = { bg_color = "#282c34", fg_color = "#e6e6e6", intensity = "Normal", italic = false, strikethrough = false, underline = "None" },
    },
  },
}

config.color_scheme = "Noctalia"

-- Fallback GPU: WebGpu (Vulkan) est incompatible wayland sur ce système (cf. obsidian vulkan error)
-- OpenGL est plus stable sous niri 26.04 + mesa. Gardé explicite pour wezterm 20240203.
config.front_end = "OpenGL"
config.enable_wayland = true

config.font = wezterm.font("JetBrains Mono")
config.font_size = 14

config.window_decorations = "RESIZE"
config.window_frame = {
  font_size = 14.0,
  active_titlebar_bg = '#62AEEF',
  inactive_titlebar_bg = '#292C34',
}

config.keys = {
  {
    key = 'n',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ToggleFullScreen,
  },
}

config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true
-- config.enable_tab_bar = false -- optional

-- Prefer the Ubuntu WSL distro when a WSL domain is available.
for _, dom in ipairs(wsl_domains) do
  if dom.name == 'WSL:Ubuntu' then
    config.default_domain = 'WSL:Ubuntu'
  end
end

return config
