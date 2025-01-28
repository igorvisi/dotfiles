-- Pull in the wezterm API
local wezterm = require "wezterm"
local wsl_domains = wezterm.default_wsl_domains()
local mux = wezterm.mux
wezterm.on("gui-startup", function()
  local tab, pane, window = mux.spawn_window{}
  window:gui_window():maximize()
end)
-- This table will hold the configuration.
local config = {}

-- For example, changing the color scheme:
config.color_scheme = 'tokyonight_night'
config.font =
    wezterm.font("JetBrains Mono")
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

-- tab bar
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true
--config.enable_tab_bar = false

for idx, dom in ipairs(wsl_domains) do
  if dom.name == 'WSL:Ubuntu' then
    config.default_domain = 'WSL:Ubuntu'
  end
end

-- and finally, return the configuration to wezterm
return config
