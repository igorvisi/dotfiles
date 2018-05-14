#!/bin/bash

# kill all xcape session
killall xcape

# Maps caps lock key to super 
setxkbmap -layout fr -option caps:super

# remap japanese keys to Ctrl+c and Ctrl+v : copy and paste
# remap Shift Right to Ctrl+ w : close tabs
# When caps is pressed only once, treat it as escape.
xcape -e 'Super_L=Escape;Henkan_Mode=Control_L|C;Hiragana_Katakana=Control_L|V;Shift_R=Control_L|W'

# remap japanese key to <>  
xmodmap -e 'keycode 132 = 0x3c 0x3e'
# make tap on touchpad become click middle
# help when you often open many tabs in browser or editor
synclient TapButton2=2

