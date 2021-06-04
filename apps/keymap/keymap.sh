#!/bin/bash

# setxkbmap -layout fr

# Show short code
# xmodmap -pk

xmodmap -e "keycode 117 = Right"

# make tap on touchpad become click middle
# help when you often open many tabs in browser or editor
synclient TapButton2=2

