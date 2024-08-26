#!/usr/bin/env bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Mandatory installations
echo -e "Installing mandatory packages: ${GREEN}zsh, sheldon, git, curl${NC}"
sudo apt update
sudo apt install -y zsh git curl

# Install Sheldon, a plugin manager for Zsh
echo -e "Installing ${GREEN}Sheldon, a plugin manager for Zsh${NC}"
curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin

# Function to prompt for optional installation
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

# Optional CLI applications
install_if_approved "bat (a cat clone with syntax highlighting)" "sudo apt install -y bat"
install_if_approved "eza (an improved ls command)" "sudo apt install -y eza"
install_if_approved "dnsutils (tools for DNS querying)" "sudo apt install -y dnsutils"
install_if_approved "GitHub CLI (gh)" "sudo apt install -y gh"
install_if_approved "tmux (a terminal multiplexer)" "sudo apt install -y tmux"
install_if_approved "Neovim (an improved version of Vim)" "sudo apt install -y neovim"

install_if_approved "trash-cli (a CLI trash manager)" "sudo apt install -y trash-cli"
install_if_approved "git-extras (Git utilities)" "sudo apt install -y git-extras"
install_if_approved "GPG (GNU Privacy Guard)" "sudo apt install -y gpg"
install_if_approved "tree (a directory listing command)" "sudo apt install -y tree"
install_if_approved "fzy (a fast fuzzy finder)" "sudo apt install -y fzy"
install_if_approved "fzf (a general-purpose fuzzy finder)" "sudo apt install -y fzf"
install_if_approved "zoxide (a smarter cd command)" "sudo apt install -y zoxide"
install_if_approved "FiraCode fonts (programming font with ligatures)" "sudo apt install -y fonts-firacode"
install_if_approved "pip for Python 3" "sudo apt install -y python3-pip"
install_if_approved "Ruby" "sudo apt install -y ruby"
install_if_approved "rkhunter (rootkit hunter)" "sudo apt install -y rkhunter"
install_if_approved "ClamAV (antivirus)" "sudo apt install -y clamav"
install_if_approved "Lynis (security auditing tool)" "sudo apt install -y lynis"
install_if_approved "Ansible (IT automation)" "sudo apt install -y ansible"

# Install mise
install_if_approved "Mise (a CLI tool to manage local .env files)" "curl https://mise.run | sh"

# Install lazydocker
install_if_approved "Lazydocker (a simple terminal UI for Docker)" "curl -sS https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash"

# Install lazygit
install_if_approved "Lazygit (a simple terminal UI for Git)" "
LAZYGIT_VERSION=\$(curl -s 'https://api.github.com/repos/jesseduffield/lazygit/releases/latest' | grep -Po '\"tag_name\": \"v\K[^\"]*')
curl -Lo lazygit.tar.gz 'https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_\${LAZYGIT_VERSION}_Linux_x86_64.tar.gz'
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit.tar.gz
"

# Install Nerd Fonts (JetBrains Mono)
install_if_approved "JetBrains Mono Nerd Fonts (programming fonts with extra symbols)" "
mkdir -p ~/.local/share/fonts
cd /tmp
wget https://github.com/ryanoasis/nerd-fonts/releases/download/latest/JetBrainsMono.zip
unzip JetBrainsMono.zip -d JetBrainsMono
cp JetBrainsMono/*.ttf ~/.local/share/fonts
rm -rf JetBrainsMono.zip JetBrainsMono
fc-cache -f -v
cd -
"

# Check for GUI environment
if systemctl list-units --type=service | grep -q display-manager; then
    echo "GUI environment detected."

    # Optional GUI applications
    install_if_approved "VLC (media player)" "sudo apt install -y vlc"
    install_if_approved "Thunderbird (email client)" "sudo apt install -y thunderbird"
    install_if_approved "Alacritty (GPU-accelerated terminal emulator)" "sudo apt install -y alacritty"
    install_if_approved "GIMP (image editor)" "sudo apt install -y gimp"
    install_if_approved "Inkscape (vector graphics editor)" "sudo apt install -y inkscape"
    install_if_approved "Darktable (photo editing)" "sudo apt install -y darktable"
    install_if_approved "FBReader (ebook reader)" "sudo apt install -y fbreader"
    install_if_approved "LibreOffice (office suite)" "sudo apt install -y libreoffice"
    install_if_approved "KeePassXC (password manager)" "sudo apt install -y keepassxc"
    install_if_approved "Klavaro (typing tutor)" "sudo apt install -y klavaro"
    install_if_approved "Postman (API testing tool)" "sudo snap install postman"
    install_if_approved "Telegram (messaging app)" "sudo snap install telegram-desktop"
    install_if_approved "Spotify (music streaming app)" "sudo snap install spotify"
    install_if_approved "Obsidian (note-taking app)" "flatpak install -y flathub md.obsidian.Obsidian"

    # Install 1Password
    install_if_approved "1Password (password manager)" "
    curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
    sudo apt update && sudo apt install -y 1password
    "

    # Install TablePlus
    install_if_approved "TablePlus (database management tool)" "
    wget -qO - https://deb.tableplus.com/apt.tableplus.com.gpg.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/tableplus-archive.gpg > /dev/null
    echo 'deb [arch=arm64] https://deb.tableplus.com/debian/24-arm tableplus main' | sudo tee /etc/apt/sources.list.d/tableplus.list
    sudo apt update && sudo apt install -y tableplus
    "

    # Install LocalSend
    install_if_approved "LocalSend (local file sharing tool)" "
    cd /tmp
    LOCALSEND_VERSION=\$(curl -s 'https://api.github.com/repos/localsend/localsend/releases/latest' | grep -Po '\"tag_name\": \"v\K[^\"]*')
    wget -O localsend.deb 'https://github.com/localsend/localsend/releases/latest/download/LocalSend-\${LOCALSEND_VERSION}-linux-x86-64.deb'
    sudo apt install -y ./localsend.deb
    rm localsend.deb
    cd -
    "

    # Install VSCode
    install_if_approved "Visual Studio Code (code editor)" "
    cd /tmp
    wget -O code.deb 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64'
    sudo apt install -y ./code.deb
    rm code.deb
    cd -
    "

    # Install Ulauncher
    install_if_approved "Ulauncher (application launcher)" "
    sudo add-apt-repository universe -y
    sudo add-apt-repository ppa:agornostal/ulauncher -y
    sudo apt update -y
    sudo apt install -y ulauncher
    "

    # Install AnyDesk
    install_if_approved "AnyDesk (remote desktop application)" "
    wget -qO - https://keys.anydesk.com/repos/DEB-GPG-KEY | sudo apt-key add -
    echo 'deb http://deb.anydesk.com/ all main' | sudo tee /etc/apt/sources.list.d/anydesk-stable.list
    sudo apt update && sudo apt install -y anydesk
    "
fi

echo "Installation script completed."
