#!/bin/bash


exec i3 -V >> /var/log/i3/log-$(date +'%F-%k-%M-%S') 2>&1
setxkbmap fr
setxkbmap -option ctrl:nocaps
xmodmap -e " keycode 132 = 0x3c 0x3e"¬
