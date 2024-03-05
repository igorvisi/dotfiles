#!/usr/bin/env bash

# Install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono


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
)

brew install ${APPS[@]}