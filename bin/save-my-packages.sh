#!/bin/bash

yay -Qq > $HOME/.extra/packages/yaourt.txt
code --list-extensions > $HOME/.extra/packages/vscode.txt
npm list -json -g --depth=0 > $HOME/.extra/packages/npm.txt
