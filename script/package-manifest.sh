#!/usr/bin/env bash

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_MANIFEST="$DOTFILES_ROOT/apps/apps.json"

manifest_packages() {
    local platform=$1
    local category=$2

    jq -r --arg platform "$platform" --arg category "$category" \
        '.[$platform][$category][]?' "$APP_MANIFEST"
}
