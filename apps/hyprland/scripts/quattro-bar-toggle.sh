#!/usr/bin/env bash
set -euo pipefail

root="$HOME/.config/hyprland-quattro/quattro/omarchy"
state_home="${XDG_STATE_HOME:-$HOME/.local/state}/hyprland-quattro/omarchy"

export OMARCHY_STATE_HOME="$state_home"
export PATH="$root/bin:$PATH"

exec omarchy-toggle-bar
