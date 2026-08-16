#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
wallpaper=$("$script_dir/wallpaper-path.sh" || true)

if [[ -n "$wallpaper" ]]; then
    exec swaybg --image "$wallpaper" --mode fill
fi

exec swaybg --color '#1e2229'
