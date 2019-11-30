#!/bin/bash

# kill all xcape session
killall xcape

setxkbmap -layout fr

# remap japanese keys to Ctrl+c and Ctrl+v : copy and paste
# remap Shift Right to Ctrl+ w : close tabs
# xcape -e 'Henkan_Mode=Control_L|C;Hiragana_Katakana=Control_L|V;'

# remap japanese key to <>  
xmodmap -e 'keycode 132 = 0x3c 0x3e'
# make tap on touchpad become click middle
# help when you often open many tabs in browser or editor
synclient TapButton2=2

