# ~/.dotfiles

This repo contains my personal dotfiles. I copy stuffs from several people and I personalize those to go better with my workflow. I remain open to any improvement ! And you are free to clone and to adapte to your sauce.

## My setup

### OS:
* MacOS for most of things
* Linux (Ubuntu) for servers/tinkering

### Tools:
Link to [my /uses page](https://igorvisi.com/uses)

### Aliases and function
* dotfiles/shell/aliases
* dotfiles/shell/functions

## Installation
Good to know beforehand, I use :
* [dotbot](github.com/anishathalye/dotbot) to manage my dotfiles.
* [sheldon](https://github.com/rossmacarthur/sheldon) to manage shell plugin.
* [mackup](https://github.com/lra/mackup) to backup most of conf.
* [eza](https://github.com/eza-community/eza) as a ls remplacement.
* [bat](https://github.com/sharkdp/bat) as a cat remplacement.
* [neovim](https://github.com/neovim/neovim) instead of vim.
* [jetbrains-mono](https://www.jetbrains.com/lp/mono/) a open source font for developers.
* [starship](https://starship.rs/) a minimal, blazing-fast, and infinitely customizable prompt for any shell!

### Clone and configure env variables
```bash
git clone https://github.com/igorvisi/dotfiles ~/.dotfiles
```
Configure according to you
~/.dotfiles/shell/global
~/.gitconfig.local

### Install conf.
```bash
cd ~/.dotfiles

# Change conf
vim shell/global apps/git/.gitconfig.local
chmod +x install

# First install for the CLI
./install

## Desktop
# You can install for Linux Desktop
./install install.linux.yaml
# Or You can install for MacOS
./install install.macos.yaml

## Install my minimal setups apps
# For linux
./linux/install.sh
# For macOS
./macos/install.sh
```