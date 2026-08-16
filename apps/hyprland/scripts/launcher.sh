#!/usr/bin/env bash
set -euo pipefail

export XDG_CONFIG_HOME="$HOME/.config/hyprland-quattro"
exec walker "$@"
