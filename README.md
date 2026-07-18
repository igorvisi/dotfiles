# ~/.dotfiles

This repository contains my personal dotfiles, managed with Dotbot.

## My setup

### OS:
* MacOS
* Linux (Ubuntu 24.04)
* Windows 11 with WSL

### Tools:
Link to [my /uses page](https://igorvisi.com/uses)

### Aliases and function
* dotfiles/shell/aliases
* dotfiles/shell/functions

## Installation
Good to know beforehand, I use:
* [dotbot](https://github.com/anishathalye/dotbot) to manage my dotfiles.
* [sheldon](https://github.com/rossmacarthur/sheldon) to manage shell plugin.
* [eza](https://github.com/eza-community/eza) as a ls remplacement.
* [bat](https://github.com/sharkdp/bat) as a cat remplacement.
* [neovim](https://github.com/neovim/neovim) instead of vim.
* [jetbrains-mono](https://www.jetbrains.com/lp/mono/) a open source font for developers.
* [starship](https://starship.rs/) a minimal, blazing-fast, and infinitely customizable prompt for any shell!
* [Mozilla thunderbird](https://www.thunderbird.net/) email client
* [localsend](https://localsend.org/) alternative to Airdrop, cross-plateform.
* [obsidian](https://obsidian.md/) flexible note‑taking app
* [vscode](https://code.visualstudio.com/) you know
* [TablePlus](https://tableplus.com/)  intuitive GUI tools to manage SQL database.

More, see [my /uses page](https://igorvisi.com/uses)

### Clone and configure env variables
```bash
git clone https://github.com/igorvisi/dotfiles ~/dotfiles
```
Configure according to you
~/dotfiles/shell/global
~/.gitconfig.local

### Install conf.
```bash
cd ~/dotfiles

# Change conf
vim shell/global apps/git/gitconfig.local
cp apps/git/gitconfig.local ~/.gitconfig.local
chmod +x install

# Install common configuration
./install

# Linux
./install install.linux.yaml

# macOS
./install install.macos.yaml

# WSL
./install install.wsl.yaml

# Install applications on Linux
./script/install.ubuntu.sh

# Install applications on macOS
./script/install.macos.sh
```

Machine-specific or sensitive application settings are intentionally kept outside Dotbot.

## Screenshots

### MacOS
![Macos](screenshot-macos.png)

### Ubuntu 24.04 LTS
![Linux](screenshot-linux.png)


### Windows 11 with WSL
![Windows ](screenshot-windows.png)
