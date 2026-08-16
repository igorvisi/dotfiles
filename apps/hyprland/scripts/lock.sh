#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
wallpaper=$("$script_dir/wallpaper-path.sh" || true)
background=(--color 1e2229)

if [[ -n "$wallpaper" ]]; then
    background=(--image "$wallpaper" --scaling fill)
fi

exec swaylock \
    "${background[@]}" \
    --daemonize \
    --font "Maple Mono" \
    --font-size 20 \
    --indicator-radius 48 \
    --indicator-thickness 3 \
    --inside-color 1e2229ee \
    --inside-clear-color 3e4451ee \
    --inside-ver-color 3e4451ee \
    --inside-wrong-color 1e2229ee \
    --ring-color 61afefff \
    --ring-clear-color 56b6c2ff \
    --ring-ver-color 98c379ff \
    --ring-wrong-color e06c75ff \
    --key-hl-color 61afefff \
    --bs-hl-color e06c75ff \
    --text-color abb2bfff \
    --text-clear-color abb2bfff \
    --text-ver-color 98c379ff \
    --text-wrong-color e06c75ff \
    --separator-color 00000000 \
    --show-failed-attempts \
    --ignore-empty-password
