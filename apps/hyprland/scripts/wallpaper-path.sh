#!/usr/bin/env bash
set -euo pipefail

wallpaper_state="${XDG_CACHE_HOME:-$HOME/.cache}/noctalia/wallpapers.json"
fallback="$HOME/Images/Wallpapers/zenitsu-agatsuma-5120x2880-24472.png"

if [[ -r "$wallpaper_state" ]]; then
    configured=$(jq -r '.wallpapers[""].dark // empty' "$wallpaper_state" 2>/dev/null || true)
    if [[ -n "$configured" && -r "$configured" ]]; then
        printf '%s\n' "$configured"
        exit 0
    fi
fi

if [[ -r "$fallback" ]]; then
    printf '%s\n' "$fallback"
    exit 0
fi

exit 1
