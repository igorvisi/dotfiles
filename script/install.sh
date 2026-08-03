#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then echo "macos"
    elif grep -qi "microsoft" /proc/version 2>/dev/null; then echo "wsl"
    elif command -v pacman &>/dev/null; then echo "arch"
    elif command -v apt &>/dev/null; then echo "ubuntu"
    else echo "unknown"
    fi
}

OS=$(detect_os)
echo "Detected OS: $OS"

# Run platform-specific install script
if [[ -f "$SCRIPT_DIR/install.${OS}.sh" ]]; then
    bash "$SCRIPT_DIR/install.${OS}.sh"
else
    echo "No install script found for $OS"
fi

# Link common files, then the platform overlay.
echo "Linking files..."
cd "$BASE_DIR"
./install install.yaml

case "$OS" in
    arch|ubuntu) OVERLAY="linux" ;;
    macos|wsl) OVERLAY="$OS" ;;
    *) OVERLAY="" ;;
esac

if [[ -n "$OVERLAY" && -f "install.${OVERLAY}.yaml" ]]; then
    ./install "install.${OVERLAY}.yaml"
fi

echo "Done."
