#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

install_if_approved() {
    local description=$1
    local install_command=$2

    echo -e "${GREEN}Do you want to install $description? [y/N]:${NC} "
    read -p "" choice
    case "$choice" in
        [yY][eE][sS]|[yY])
            eval "$install_command"
            ;;
        *)
            echo -e "${RED}Skipping $description.${NC}"
            ;;
    esac
}

# Bootstrap packages required to build AUR packages.
sudo pacman -S --needed --noconfirm base-devel git

# Install yay (AUR helper)
if ! command -v yay &>/dev/null; then
    echo -e "${GREEN}Installing yay...${NC}"
    cd /tmp && git clone --depth 1 https://aur.archlinux.org/yay-bin.git
    cd yay-bin && makepkg -si --noconfirm
    cd -
fi

# Mandatory packages
echo -e "${GREEN}Installing mandatory packages...${NC}"
sudo pacman -S --needed --noconfirm neovim tmux starship zsh curl wget fzf zoxide eza bat ripgrep jq tree htop gpg pipewire pipewire-pulse wireplumber polkit-kde-agent

# Dev tools
echo -e "${GREEN}Installing dev tools...${NC}"

install_if_approved "Sheldon (Zsh plugin manager)" 'curl --proto "=https" -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin'

install_if_approved "TPM (Tmux Plugin Manager)" 'git clone --depth 1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'

install_if_approved "vim-plug (Neovim plugin manager)" 'curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

install_if_approved "GitHub CLI (gh)" 'sudo pacman -S --needed --noconfirm github-cli'

install_if_approved "fzy (a fast fuzzy finder)" 'sudo pacman -S --needed --noconfirm fzy'

install_if_approved "trash-cli (a CLI trash manager)" 'sudo pacman -S --needed --noconfirm trash-cli'

install_if_approved "git-extras (Git utilities)" 'yay -S --needed --noconfirm git-extras'

install_if_approved "Lazygit" 'sudo pacman -S --needed --noconfirm lazygit || yay -S --needed --noconfirm lazygit'

install_if_approved "Lazydocker" 'curl -sS https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash'

install_if_approved "Docker" 'sudo pacman -S --needed --noconfirm docker'

install_if_approved "Mise (a CLI tool to manage local .env files)" 'curl https://mise.run | sh'

# Security tools
install_if_approved "rkhunter (rootkit hunter)" 'sudo pacman -S --needed --noconfirm rkhunter'

install_if_approved "ClamAV (antivirus)" 'sudo pacman -S --needed --noconfirm clamav'

install_if_approved "Lynis (security auditing tool)" 'sudo pacman -S --needed --noconfirm lynis'

install_if_approved "Ansible (IT automation)" 'sudo pacman -S --needed --noconfirm ansible'

# GUI packages
if systemctl list-units --type=service 2>/dev/null | grep -q display-manager || [[ -n "$WAYLAND_DISPLAY" ]]; then
    echo -e "${GREEN}GUI environment detected.${NC}"

    # Wayland/Arch specific
    install_if_approved "Alacritty (GPU-accelerated terminal emulator)" "sudo pacman -S --needed --noconfirm alacritty"
    install_if_approved "Niri (scrollable tiling Wayland compositor)" "sudo pacman -S --needed --noconfirm niri"
    install_if_approved "Fuzzel (Wayland app launcher)" "sudo pacman -S --needed --noconfirm fuzzel"
    install_if_approved "Wlr-randr (Wayland display configuration)" "sudo pacman -S --needed --noconfirm wlr-randr"
    install_if_approved "Swaylock (screen locker)" "sudo pacman -S --needed --noconfirm swaylock"
    install_if_approved "Grim + Slurp (screenshot tools)" "sudo pacman -S --needed --noconfirm grim slurp"
    install_if_approved "Nautilus (file manager)" "sudo pacman -S --needed --noconfirm nautilus"

    # Common GUI apps
    install_if_approved "VLC (media player)" "sudo pacman -S --needed --noconfirm vlc"
    install_if_approved "Thunderbird (email client)" "sudo pacman -S --needed --noconfirm thunderbird"
    install_if_approved "Telegram (messaging app)" "sudo pacman -S --needed --noconfirm telegram-desktop"
    install_if_approved "Spotify" "yay -S --needed --noconfirm spotify"
    install_if_approved "Brave browser" "yay -S --needed --noconfirm brave-bin"
    install_if_approved "Obsidian (note-taking app)" "sudo pacman -S --needed --noconfirm obsidian"
    install_if_approved "1Password (password manager)" "yay -S --needed --noconfirm 1password"
    install_if_approved "KeePassXC (password manager)" "sudo pacman -S --needed --noconfirm keepassxc"
    install_if_approved "GIMP (image editor)" "sudo pacman -S --needed --noconfirm gimp"
    install_if_approved "Inkscape (vector graphics editor)" "sudo pacman -S --needed --noconfirm inkscape"
    install_if_approved "FBReader (ebook reader)" "sudo pacman -S --needed --noconfirm fbreader"
    install_if_approved "Klavaro (typing tutor)" "sudo pacman -S --needed --noconfirm klavaro"
    install_if_approved "LocalSend (local file sharing tool)" "yay -S --needed --noconfirm localsend"
    install_if_approved "VSCode (code editor)" "yay -S --needed --noconfirm visual-studio-code-bin"
    install_if_approved "Zed (code editor)" "sudo pacman -S --needed --noconfirm zed"
    install_if_approved "TablePlus (database management tool)" "yay -S --needed --noconfirm tableplus"
    install_if_approved "AnyDesk (remote desktop application)" "yay -S --needed --noconfirm anydesk-bin"

    # Fonts
    install_if_approved "JetBrains Mono Nerd Fonts" '
    mkdir -p ~/.local/share/fonts
    cd /tmp
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/latest/JetBrainsMono.zip
    unzip JetBrainsMono.zip -d JetBrainsMono
    cp JetBrainsMono/*.ttf ~/.local/share/fonts
    rm -rf JetBrainsMono.zip JetBrainsMono
    fc-cache -f -v
    cd -
    '

    install_if_approved "Maple Mono NF (programming font)" '
    mkdir -p ~/.local/share/fonts
    cd /tmp
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/latest/MapleMono.zip
    unzip MapleMono.zip -d MapleMono
    cp MapleMono/*.ttf ~/.local/share/fonts
    rm -rf MapleMono.zip MapleMono
    fc-cache -f -v
    cd -
    '
fi

echo -e "${GREEN}Installation script completed.${NC}"
