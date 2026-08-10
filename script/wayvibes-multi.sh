#!/bin/sh
# Keep WayVibes running for all available keyboards.
# Detects from /dev/input/by-id/*-event-kbd and /dev/input/by-path/*-event-kbd,
# plus *-event-mouse entries (some wireless combos like the Logitech K400 Plus
# are reported by the kernel as mouse interfaces even though they carry a
# keyboard), deduplicates by resolved event path, skips touchpads and mice,
# waits for each device, then launches one WayVibes per keyboard. The device
# list is monitored so hot-plugging a keyboard restarts the managed instances.
#
# WayVibes aborts in pa_channel_map_init_extend (libpulse) when its pulse
# backend queries the default sink before one is enumerated: WirePlumber has
# not created the sink yet, the sink info stays zeroed, miniaudio reports
# success anyway, and channels == 0 fails the pa_channels_valid() assertion.
# "pactl info" succeeds as soon as the pulse socket exists, before any sink,
# so wait_audio is not enough: we must also wait for a sink with a usable
# channel count before launching any WayVibes instance.

SOUNDPACK="$HOME/.wayvibes/soundpacks/cherrymx-black-pbt"
AUDIO_TIMEOUT=50
DEVICE_TIMEOUT=30
DEVICE_POLL_INTERVAL=1
wayvibes_pids=""

wait_audio() {
    attempts=0
    until pactl info >/dev/null 2>&1; do
        attempts=$((attempts + 1))
        [ "$attempts" -ge "$AUDIO_TIMEOUT" ] && return 1
        sleep 0.1
    done
}

wait_sink() {
    attempts=0
    while ! pactl get-sink-volume '@DEFAULT_SINK@' >/dev/null 2>&1 \
        || ! pactl list sinks 2>/dev/null | grep -q 'Sample Specification:.* [1-9][0-9]*ch '; do
        attempts=$((attempts + 1))
        [ "$attempts" -ge "$AUDIO_TIMEOUT" ] && return 1
        sleep 0.2
    done
}

wait_device() {
    attempts=0
    while [ ! -e "$1" ]; do
        attempts=$((attempts + 1))
        [ "$attempts" -ge "$DEVICE_TIMEOUT" ] && return 1
        sleep 1
    done
}

device_name() {
    real=$(readlink -f "$1")
    namefile="/sys/class/input/$(basename "$real")/device/name"
    [ -f "$namefile" ] && cat "$namefile"
}

is_keyboard() {
    case "$1" in
        *[Tt]ouchpad*|*[Ss]tylus*|[Ee]LAN*|[Ss]ynaptics*|[Ww]acom*|\
        *[Mm]ouse*|*[Cc]onsumer*|*[Ss]ystem*|*[Cc]ontrol*|*[Hh]otkey*|\
        *[Vv]irtual*|*[Pp]ower*|*[Bb]utton*|*[Ss]witch*|*[Ll]id*) return 1 ;;
        *) return 0 ;;
    esac
}

keyboard_devices() {
    for kbd in /dev/input/by-id/*-event-kbd /dev/input/by-id/*-event-mouse \
        /dev/input/by-path/*-event-kbd /dev/input/by-path/*-event-mouse; do
        [ -e "$kbd" ] || continue
        real=$(readlink -f "$kbd")
        name=$(device_name "$kbd")
        [ -n "$name" ] && is_keyboard "$name" && printf '%s\n' "$real"
    done | sort -u
}

stop_wayvibes() {
    for pid in $wayvibes_pids; do
        kill "$pid" 2>/dev/null || true
    done
    for pid in $wayvibes_pids; do
        wait "$pid" 2>/dev/null || true
    done
    wayvibes_pids=""
}

wayvibes_running() {
    [ -n "$wayvibes_pids" ] || return 1
    for pid in $wayvibes_pids; do
        kill -0 "$pid" 2>/dev/null || return 1
    done
}

start_wayvibes() {
    seen=""

    for kbd in /dev/input/by-id/*-event-kbd /dev/input/by-id/*-event-mouse \
        /dev/input/by-path/*-event-kbd /dev/input/by-path/*-event-mouse; do
        [ -e "$kbd" ] || continue

        real=$(readlink -f "$kbd")
        case " $seen " in *" $real "*) continue ;; esac
        seen="$seen $real"

        name=$(device_name "$kbd")
        [ -n "$name" ] && is_keyboard "$name" || continue

        wait_device "$kbd" || continue
        wayvibes --device-name "$name" "$SOUNDPACK" -v 0.5 &
        wayvibes_pids="$wayvibes_pids $!"
    done
}

wait_audio || exit 1
wait_sink || exit 1

trap 'stop_wayvibes; exit 0' HUP INT TERM

active_devices=""
while :; do
    current_devices=$(keyboard_devices)
    if [ "$current_devices" != "$active_devices" ] || ! wayvibes_running; then
        # Let all interfaces of a newly added device settle before rescanning.
        sleep "$DEVICE_POLL_INTERVAL"
        current_devices=$(keyboard_devices)
        stop_wayvibes
        start_wayvibes
        active_devices=$current_devices
    fi
    sleep "$DEVICE_POLL_INTERVAL"
done
