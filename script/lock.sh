#!/bin/bash

# Lock screen wrapper that works in both GNOME and Niri/Noctalia-shell

if command -v noctalia &>/dev/null && noctalia msg session lock 2>/dev/null; then
    exit 0
fi

# Fallback to loginctl (works in GNOME, Sway, etc.)
loginctl lock-session
