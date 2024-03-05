#!/usr/bin/env bash

# Install my very minimal must tools for Linux (Ubuntu) !
APPS=(
zsh
bat
exa
dnsutils
git
gh
tmux
neovim
trash-cli
git-extras
curl
gpg
tree
fzy
fzf
zoxide
fonts-firacode
python3-pip
ruby
)

sudo apt install ${APPS[@]}

# Install sheldon, a shell plugin manager
curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
    | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin

# Install mackup for backup/restore conf
pip install --upgrade mackup
