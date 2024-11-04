-- Pull in the wezterm API
local wezterm = require "wezterm"

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- For example, changing the color scheme:
config.color_scheme = "OneDark (base16)"
config.font =
    wezterm.font("JetBrains Mono NL")
config.font_size = 16

config.window_decorations = "RESIZE"

config.window_frame = {
--font_size = 12.0,
  active_titlebar_bg = '#62AEEF',
  inactive_titlebar_bg = '#292C34',
}

-- tab bar
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true
--config.enable_tab_bar = false

-- and finally, return the configuration to wezterm
return config
