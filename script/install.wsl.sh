#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# WSL uses Ubuntu packages while install.sh applies WSL-specific dotfile links.
bash "$SCRIPT_DIR/install.ubuntu.sh"
