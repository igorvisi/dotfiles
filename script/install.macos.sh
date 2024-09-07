#!/usr/bin/env bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Install Homebrew, a package manager for macOS
echo -e "${GREEN}Installing Homebrew...${NC}"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Tap additional repositories for Homebrew
brew tap homebrew/cask-fonts
brew tap localsend/localsend

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

# Mandatory CLI tools installation
MANDATORY_APPS=(
    zsh
    git
    curl
    sheldon
)
echo -e "${GREEN}Installing mandatory CLI tools: zsh, git, curl, sheldon...${NC}"
brew install ${MANDATORY_APPS[@]}

# Optional CLI tools
install_if_approved "tmux (a terminal multiplexer)" "brew install tmux"
install_if_approved "bat (a cat clone with syntax highlighting)" "brew install bat"
install_if_approved "eza (an improved ls command)" "brew install eza"
install_if_approved "GitHub CLI (gh)" "brew install gh"
install_if_approved "dig (DNS query utility)" "brew install bind"
install_if_approved "Mackup (backup and restore application settings)" "brew install mackup"
install_if_approved "mas (Mac App Store CLI)" "brew install mas"
install_if_approved "Neovim (an improved version of Vim)" "brew install neovim"
install_if_approved "trash-cli (a CLI trash manager)" "brew install trash-cli"
install_if_approved "GPG (GNU Privacy Guard)" "brew install gpg"
install_if_approved "tree (a directory listing command)" "brew install tree"
install_if_approved "prompt-ship (a powerful prompt theme)" "brew install prompt-ship"
install_if_approved "fzy (a fast fuzzy finder)" "brew install fzy"
install_if_approved "fzf (a general-purpose fuzzy finder)" "brew install fzf"
install_if_approved "git-delta (a syntax-highlighting pager for git)" "brew install git-delta"
install_if_approved "zoxide (a smarter cd command)" "brew install zoxide"
install_if_approved "Docker (containerization platform)" "brew install docker"
install_if_approved "btop (a system monitoring tool)" "brew install btop"
install_if_approved "rkhunter (rootkit hunter)" "brew install rkhunter"
install_if_approved "ClamAV (antivirus)" "brew install clamav"
install_if_approved "Lynis (security auditing tool)" "brew install lynis"
install_if_approved "Ansible (IT automation)" "brew install ansible"
install_if_approved "Valet (dev env for PHP)" "composer global require laravel/valet"

APP_DESK=(
    "1Password (password manager)" "brew install --cask 1password"
    "Obsidian (note-taking app)" "brew install --cask obsidian"
    "Todoist (task manager)" "brew install --cask todoist"
    "Beeper (unified messaging platform)" "brew install --cask beeper"
    "Thunderbird (email client)" "brew install --cask thunderbird"
    "VLC (media player)" "brew install --cask vlc"
    "Telegram (messaging app)" "brew install --cask telegram"
    "Spotify (music streaming app)" "brew install --cask spotify"
    "KeePassXC (password manager)" "brew install --cask keepassxc"
    "FBReader (ebook reader)" "brew install --cask fbreader"
    "Raycast (productivity tool)" "brew install --cask raycast"
    "iTerm2 (terminal emulator)" "brew install --cask iterm2"
    "JetBrains Mono (programming fonts with ligatures)" "brew install --cask jetbrains-mono"
    "TablePlus (database management tool)" "brew install --cask tableplus"
    "Brave Browser" "brew install --cask brave-browser"
    "Firefox" "brew install --cask firefox"
    "Microsoft Edge" "brew install --cask microsoft-edge"
    "Klavaro (typing tutor)" "brew install --cask klavaro"
    "OneDrive" "brew install --cask onedrive"
    "Google Drive" "brew install --cask google-drive"
    "Visual Studio Code (code editor)" "brew install --cask visual-studio-code"
    "Zed (code editor)" "brew install --cask zed"
    "LocalSend (local file sharing tool)" "brew install --cask localsend"
    "Lazygit (a simple terminal UI for Git)" "brew install lazygit"
    "AnyDesk (remote desktop application)" "brew install --cask anydesk"
)

for ((i=0; i<${#APP_DESK[@]}; i+=2)); do
    install_if_approved "${APP_DESK[$i]}" "${APP_DESK[$i+1]}"
done


# Vim Plug installation for Neovim plugin management
install_if_approved "Vim Plug (plugin manager for Neovim)" "
sh -c 'curl -fLo \"\${XDG_DATA_HOME:-\$HOME/.local/share}\"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
"

# Install Starship prompt, a minimalistic, powerful prompt for your shell
install_if_approved "Starship prompt" "curl -sS https://starship.rs/install.sh | sh"

# Install Mise, a tool to manage local .env files
install_if_approved "Mise (a CLI tool to manage local .env files)" "curl https://mise.run | sh"

# Install Lazydocker, a simple terminal UI for Docker
install_if_approved "Lazydocker (a simple terminal UI for Docker)" "curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash"

# Install JetBrains Mono Nerd Fonts (programming fonts with extra symbols)
install_if_approved "JetBrains Mono Nerd Fonts (programming fonts with extra symbols)" "
mkdir -p ~/Library/Fonts
cd /tmp
wget https://github.com/ryanoasis/nerd-fonts/releases/download/latest/JetBrainsMono.zip
unzip JetBrainsMono.zip -d JetBrainsMono
cp JetBrainsMono/*.ttf ~/Library/Fonts
rm -rf JetBrainsMono.zip JetBrainsMono
cd -
"

echo -e "${GREEN}Installation script completed.${NC}"
