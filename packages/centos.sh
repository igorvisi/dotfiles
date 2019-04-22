#!/usr/bin/env bash

sudo curl -o /etc/yum.repos.d/konimex-neofetch-epel-7.repo https://copr.fedorainfracloud.org/coprs/konimex/neofetch/repo/epel-7/konimex-neofetch-epel-7.repo

sudo yum install neovim zsh git tig tmux wget python-setuptools python-pip

sudo easy_install trash-cli

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf

cd ~/.fzf/
./install


wget -c https://github.com/ogham/exa/releases/download/v0.8.0/exa-linux-x86_64-0.8.0.zip

unzip exa-linux-x86_64-0.8.0.zip
sudo mv exa-linux-x86_64 /usr/local/bin/exa

git clone --depth 1 https://github.com/jhawthorn/fzy ~/.fzy
cd ~/.fzf
make
sudo make install

sudo pip install cheat

