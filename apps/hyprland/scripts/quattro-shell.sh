#!/usr/bin/env bash
set -euo pipefail

root="$HOME/.config/hyprland-quattro/quattro/omarchy"
state_home="${XDG_STATE_HOME:-$HOME/.local/state}/hyprland-quattro/omarchy"

export OMARCHY_PATH="$root"
export OMARCHY_CONFIG_HOME="$state_home/config"
export OMARCHY_STATE_HOME="$state_home"
export OMARCHY_THEME_PATH="$root/theme"
export PATH="$root/bin:$PATH"

exec qs -p "$root/shell" "$@"
