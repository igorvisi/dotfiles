#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
CLI_ONLY=${DOTFILES_CLI_ONLY:-0}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

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

sudo apt-get update
sudo apt-get install -y curl git jq

source "$SCRIPT_DIR/package-manifest.sh"

install_apt_category() {
    local category=$1
    local packages=()

    mapfile -t packages < <(manifest_packages ubuntu "$category")
    if ((${#packages[@]})); then
        sudo apt-get install -y "${packages[@]}"
    fi
}

prompt_apt_category() {
    local category=$1
    local package

    while IFS= read -r package; do
        install_if_approved "$package" "sudo apt-get install -y '$package'"
    done < <(manifest_packages ubuntu "$category")
}

printf "%bInstalling required CLI packages...%b\n" "$GREEN" "$NC"
install_apt_category required_cli

if ! command -v sheldon >/dev/null 2>&1; then
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
        | bash -s -- --repo rossmacarthur/sheldon --to "$HOME/.local/bin"
fi

if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sh
fi

prompt_apt_category optional_cli
install_if_approved "TPM (Tmux Plugin Manager)" \
    '[[ -d "$HOME/.tmux/plugins/tpm" ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"'
install_if_approved "Mise" 'command -v mise >/dev/null 2>&1 || curl https://mise.run | sh'
install_if_approved "Lazydocker" \
    'command -v lazydocker >/dev/null 2>&1 || curl -sS https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash'

if [[ "$CLI_ONLY" != "1" ]] && { [[ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]] || systemctl list-units --type=service 2>/dev/null | grep -q display-manager; }; then
    prompt_apt_category optional_desktop
fi

printf "%bInstallation complete.%b\n" "$GREEN" "$NC"
