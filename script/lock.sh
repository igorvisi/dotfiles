#!/bin/bash

# Lock screen wrapper that works in both GNOME and Niri/Noctalia-shell

if command -v qs &>/dev/null && pgrep -x noctalia-shell &>/dev/null; then
    # Noctalia-shell is running
    qs -c noctalia-shell ipc call lockScreen lock
else
    # Fallback to loginctl (works in GNOME, Sway, etc.)
    loginctl lock-session
fi
