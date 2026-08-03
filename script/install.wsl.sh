#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if command -v pacman >/dev/null 2>&1; then
    DOTFILES_CLI_ONLY=1 bash "$SCRIPT_DIR/install.arch.sh"
elif command -v apt-get >/dev/null 2>&1; then
    DOTFILES_CLI_ONLY=1 bash "$SCRIPT_DIR/install.ubuntu.sh"
else
    printf 'Unsupported WSL distribution: expected pacman or apt-get.\n' >&2
    exit 1
fi
