#!/bin/sh
# Keep cliphist store watchers running (text + images) so new copies land
# in history for walker (SUPER+V) and friends.
# Idempotent: safe to run on every compositor (re)start; already-running
# watchers are left alone. The [w] bracket trick keeps pgrep from matching
# anything but real wl-paste watchers.
if ! pgrep -f "[w]l-paste --type text --watch cliphist store" >/dev/null 2>&1; then
    wl-paste --type text --watch cliphist store >/dev/null 2>&1 &
fi
if ! pgrep -f "[w]l-paste --type image --watch cliphist store" >/dev/null 2>&1; then
    wl-paste --type image --watch cliphist store >/dev/null 2>&1 &
fi
