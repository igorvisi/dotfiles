#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'
CLI_ONLY=${DOTFILES_CLI_ONLY:-0}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/package-manifest.sh"

install_if_approved() {
    local description=$1
    local install_command=$2
    local choice

    printf "%bInstall %s? [y/N]:%b " "$GREEN" "$description" "$NC"
    read -r choice
    case "$choice" in
        [yY]|[yY][eE][sS]) eval "$install_command" ;;
        *) printf "%bSkipping %s.%b\n" "$RED" "$description" "$NC" ;;
    esac
}

install_pacman_category() {
    local category=$1
    local packages=()

    mapfile -t packages < <(manifest_packages arch "$category")
    if ((${#packages[@]})); then
        sudo pacman -S --needed --noconfirm "${packages[@]}"
    fi
}

install_yay_category() {
    local category=$1
    local packages=()

    mapfile -t packages < <(manifest_packages arch "$category")
    if ((${#packages[@]})); then
        yay -S --needed --noconfirm "${packages[@]}"
    fi
}

prompt_pacman_category() {
    local category=$1
    local package

    while IFS= read -r package; do
        install_if_approved "$package" "sudo pacman -S --needed --noconfirm '$package'"
    done < <(manifest_packages arch "$category")
}

prompt_yay_category() {
    local category=$1
    local package

    while IFS= read -r package; do
        install_if_approved "$package" "ensure_yay && yay -S --needed --noconfirm '$package'"
    done < <(manifest_packages arch "$category")
}

ensure_yay() {
    if command -v yay >/dev/null 2>&1; then
        return
    fi

    sudo pacman -S --needed --noconfirm base-devel

    local build_dir
    build_dir=$(mktemp -d)
    git clone --depth 1 https://aur.archlinux.org/yay-bin.git "$build_dir/yay-bin"
    (
        cd "$build_dir/yay-bin"
        makepkg -si --noconfirm
    )
    rm -rf "$build_dir"
}

setup_voxtype() {
    local model="$HOME/.local/share/voxtype/models/ggml-small.bin"

    if command -v voxtype >/dev/null 2>&1 && [[ ! -f "$model" ]]; then
        printf "%bDownloading the Voxtype small model...%b\n" "$GREEN" "$NC"
        voxtype setup --download --model small --no-post-install
    fi
}

setup_wayvibes() {
    local soundpack="$HOME/.wayvibes/soundpacks/cherrymx-black-pbt"
    local device_config="${XDG_CONFIG_HOME:-$HOME/.config}/wayvibes/input_device"

    if [[ ! -d "$soundpack" ]]; then
        if [[ -e "$HOME/.wayvibes" ]]; then
            printf "%bWayVibes exists but the Cherry MX Black PBT soundpack is missing: %s%b\n" \
                "$YELLOW" "$HOME/.wayvibes" "$NC"
        else
            git clone --depth 1 https://github.com/sahaj-b/wayvibes.git "$HOME/.wayvibes"
        fi
    fi

    if [[ " $(id -nG "$USER") " != *" input "* ]]; then
        sudo usermod -aG input "$USER"
        printf "%bLog out and back in to activate WayVibes input access.%b\n" "$YELLOW" "$NC"
    fi

    if [[ ! -f "$device_config" ]]; then
        printf "%bAfter logging back in, run 'wayvibes --device %q' once to select the keyboard.%b\n" \
            "$YELLOW" "$soundpack" "$NC"
    fi
}

setup_hyprland_quattro_session() {
    sudo install -Dm755 "$SCRIPT_DIR/hyprland-quattro-session" \
        /usr/local/bin/hyprland-quattro-session
    sudo install -Dm644 "$DOTFILES_ROOT/apps/hyprland/session/hyprland-quattro.desktop" \
        /usr/share/wayland-sessions/hyprland-quattro.desktop
}

sudo pacman -S --needed --noconfirm git jq

printf "%bInstalling required CLI packages...%b\n" "$GREEN" "$NC"
install_pacman_category required_cli
prompt_pacman_category optional_cli
prompt_yay_category optional_aur_cli

install_if_approved "TPM (Tmux Plugin Manager)" \
    '[[ -d "$HOME/.tmux/plugins/tpm" ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"'
install_if_approved "Mise" 'command -v mise >/dev/null 2>&1 || curl https://mise.run | sh'
install_if_approved "Lazydocker" \
    'command -v lazydocker >/dev/null 2>&1 || curl -sS https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash'

if [[ "$CLI_ONLY" != "1" ]]; then
    printf "%bInstalling required Wayland desktop packages...%b\n" "$GREEN" "$NC"
    install_pacman_category required_desktop
    ensure_yay
    install_yay_category required_aur_desktop
    setup_hyprland_quattro_session
    setup_voxtype
    setup_wayvibes
    prompt_pacman_category optional_desktop
    prompt_yay_category optional_aur_desktop
fi

printf "%bInstallation complete.%b\n" "$GREEN" "$NC"
