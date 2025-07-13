local wezterm = require "wezterm"
local mux = wezterm.mux



local config = {}

-- Détection du shell
local shell = os.getenv("SHELL") or "/bin/zsh"


-- Utiliser tmux comme programme par défaut si installé


wezterm.on("gui-startup", function(cmd)

  -- Pour Macos, on utilise le shell interactif
  if wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple:find("darwin") then
    local tab, pane, window = mux.spawn_window {
      -- forcer un shell interactif et login (-l -i)
      args = { shell, "-l", "-i", "-c", "tmux attach -t main || tmux new -s main" },
      domain = cmd and cmd.domain or nil,
    }
    window:gui_window():maximize()
  end
  -- Pour Linux/WSL
  if wezterm.target_triple:find("linux") and not wezterm.target_triple:find("darwin") then
    local tab, pane, window = mux.spawn_window {
      args = { shell, "-c", "tmux attach -t main || tmux new -s main" },
      domain = cmd and cmd.domain or nil,
    }
    window:gui_window():maximize()
  end
end)

-- Couleurs, police, etc.
config.color_scheme = 'tokyonight_night'
config.font = wezterm.font("JetBrains Mono")
config.font_size = 16
config.window_decorations = "RESIZE"
config.window_frame = {
  font_size = 14.0,
  active_titlebar_bg = '#62AEEF',
  inactive_titlebar_bg = '#292C34',
}

-- Raccourcis
config.keys = {
  {
    key = 'n',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ToggleFullScreen,
  },
}

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true

-- WSL domain (Windows uniquement)
local wsl_domains = wezterm.default_wsl_domains()
for _, dom in ipairs(wsl_domains) do
  if dom.name == 'WSL:Ubuntu' then
    config.default_domain = 'WSL:Ubuntu'
  end
end

return config

