#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"
APPS_JSON="$BASE_DIR/apps/apps.json"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then echo "macos"
    elif grep -qi "microsoft" /proc/version 2>/dev/null; then echo "wsl"
    elif command -v pacman &>/dev/null; then echo "arch"
    elif command -v apt &>/dev/null; then echo "ubuntu"
    else echo "unknown"
    fi
}

# Detect GUI
has_gui() {
    if [[ "$OS" == "macos" ]]; then return 0
    elif [[ "$OS" == "wsl" ]]; then return 1
    elif systemctl list-units --type=service 2>/dev/null | grep -q display-manager; then return 0
    elif [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]; then return 0
    else return 1
    fi
}

# Parse JSON and get packages
get_packages() {
    local type=$1
    python3 -c "
import json, sys
with open('$APPS_JSON') as f:
    data = json.load(f)
pkgs = data.get('$type', {}).get('$OS', {})
print(' '.join(pkgs.values()))
"
}

# Install packages
install_packages() {
    local type=$1
    local pkgs=$(get_packages "$type")
    [[ -z "$pkgs" ]] && return

    echo "Installing $type packages..."
    case $OS in
        arch)
            if [[ "$type" == "aur" ]]; then
                yay -S --needed --noconfirm $pkgs
            else
                sudo pacman -S --needed --noconfirm $pkgs
            fi
            ;;
        ubuntu)
            sudo apt update && sudo apt install -y $pkgs
            ;;
        macos)
            brew install $pkgs
            ;;
    esac
}

# Install dev tools
install_tools() {
    echo "Installing dev tools..."
    
    # sheldon
    if ! command -v sheldon &>/dev/null; then
        curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
    fi

    # TPM
    if [[ ! -d ~/.tmux/plugins/tpm ]]; then
        git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    fi

    # vim-plug
    if [[ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]]; then
        curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
}

# Link files with dotbot
link_files() {
    echo "Linking files..."
    cd "$BASE_DIR"
    if [[ -f "install.${OS}.yaml" ]]; then
        ./install "install.${OS}.yaml"
    else
        ./install install.yaml
    fi
}

# Main
OS=$(detect_os)
echo "Detected OS: $OS"

# Install yay for AUR on Arch
if [[ "$OS" == "arch" ]] && ! command -v yay &>/dev/null; then
    echo "Installing yay..."
    cd /tmp && git clone --depth 1 https://aur.archlinux.org/yay-bin.git
    cd yay-bin && makepkg -si --noconfirm
    cd "$BASE_DIR"
fi

install_packages cli

if has_gui; then
    install_packages gui
fi

if [[ "$OS" == "arch" ]]; then
    install_packages aur
fi

install_tools
link_files

echo "Done."
