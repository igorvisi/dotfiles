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

config.color_scheme = 'tokyonight_night'

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
