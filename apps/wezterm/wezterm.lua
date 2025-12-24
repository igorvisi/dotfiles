-- Chargement de l'API de wezterm
local wezterm = require "wezterm"
local mux = wezterm.mux

-- Détection des domaines WSL pour Windows
local wsl_domains = wezterm.default_wsl_domains()

-- Fonction exécutée au lancement de l'interface graphique
wezterm.on("gui-startup", function(cmd)
  -- Utiliser zsh comme shell par défaut (ou fallback vers /bin/sh)
  local shell = os.getenv("SHELL") or "zsh"

  local tmux_cmd = shell .. ' -c "tmux attach -t main || tmux new -s main"'

  -- Créer une seule fenêtre avec la commande tmux
  local tab, pane, window = mux.spawn_window {
    args = { shell, "-c", "tmux attach -t main || tmux new -s main" },
    domain = cmd and cmd.domain or nil,
  }

  -- Maximiser automatiquement la fenêtre
  window:gui_window():maximize()
end)

-- Début de la table de configuration
local config = {}

-- Schéma de couleurs
config.color_scheme = 'tokyonight_night'

-- Police et taille de police
config.font = wezterm.font("JetBrains Mono")
config.font_size = 14

-- Décorations de la fenêtre
config.window_decorations = "RESIZE"
config.window_frame = {
  font_size = 14.0,
  active_titlebar_bg = '#62AEEF',
  inactive_titlebar_bg = '#292C34',
}

-- Raccourcis personnalisés
config.keys = {
  {
    key = 'n',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ToggleFullScreen,
  },
}

-- Configuration de la barre d’onglets
config.hide_tab_bar_if_only_one_tab = true
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true
-- config.enable_tab_bar = false -- facultatif

-- Utiliser un domaine WSL spécifique si présent
for _, dom in ipairs(wsl_domains) do
  if dom.name == 'WSL:Ubuntu' then
    config.default_domain = 'WSL:Ubuntu'
  end
end

-- Retour de la configuration à wezterm
return config
