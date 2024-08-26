#!/usr/bin/env bash

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew tap homebrew/cask-fonts

# Install my very minimal must tools for MacOS !
APPS=(
zsh
tmux
bat
eza
git
gh
dig
mackup
mas
neovim
trash-cli
curl
gpg
tree
sheldon
prompt-ship
fzy
fzf
git-delta
zoxide
docker
btop
rkhunter
clamav
lynis
ansible
)

brew install ${APPS[@]}



APP_DESK=(
1password
obsidian
todoist
beeper
readdle-spark
vlc
raycast
iterm2
font-jetbrains-mono
tableplus
brave-browser
firefox
microsoft-edge
klavaro
onedrive
google-drive
)
brew install --cask ${APPS_DESK[@]}


# Vim Plug
sh -c 'curl -fLo \"${XDG_DATA_HOME:-$HOME/.local/share}\"/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# Install starship prompt
curl -sS https://starship.rs/install.sh | sh