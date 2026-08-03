#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
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

if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if ! command -v brew >/dev/null 2>&1; then
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    else
        printf '%bHomebrew installation did not provide a usable brew command.%b\n' "$RED" "$NC" >&2
        exit 1
    fi
fi

brew install jq
source "$SCRIPT_DIR/package-manifest.sh"

install_brew_category() {
    local category=$1
    local package

    while IFS= read -r package; do
        brew list --formula "$package" >/dev/null 2>&1 || brew install "$package"
    done < <(manifest_packages macos "$category")
}

prompt_brew_category() {
    local category=$1
    local package

    while IFS= read -r package; do
        install_if_approved "$package" "brew install '$package'"
    done < <(manifest_packages macos "$category")
}

prompt_cask_category() {
    local category=$1
    local package

    while IFS= read -r package; do
        install_if_approved "$package" "brew install --cask '$package'"
    done < <(manifest_packages macos "$category")
}

printf "%bInstalling required CLI packages...%b\n" "$GREEN" "$NC"
install_brew_category required_cli
prompt_brew_category optional_cli
prompt_cask_category optional_casks

install_if_approved "TPM (Tmux Plugin Manager)" \
    '[[ -d "$HOME/.tmux/plugins/tpm" ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"'
install_if_approved "Mise" 'command -v mise >/dev/null 2>&1 || curl https://mise.run | sh'

printf "%bInstallation complete.%b\n" "$GREEN" "$NC"
