#!/bin/bash

# Lock screen wrapper that works in both GNOME and Niri/Noctalia-shell

if command -v qs &>/dev/null && qs -c noctalia-shell ipc call lockScreen lock; then
    exit 0
fi

# Fallback to loginctl (works in GNOME, Sway, etc.)
loginctl lock-session
