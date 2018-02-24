#!/bin/bash

sudo pacman -Qq > $HOME/.extra/packages/yaourt.txt
code --list-extensions > $HOME/.extra/packages/vscode.txt
ls $HOME/.yarn/bin > $HOME/.extra/packages/yarn.txt
