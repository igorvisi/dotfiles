#!/bin/sh
# Launch WayVibes for all available keyboards.
# Detects from /dev/input/by-id/*-event-kbd and /dev/input/by-path/*-event-kbd,
# plus *-event-mouse entries (some wireless combos like the Logitech K400 Plus
# are reported by the kernel as mouse interfaces even though they carry a
# keyboard), deduplicates by resolved event path, skips touchpads and mice,
# waits for each device, then launches one WayVibes per keyboard.
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

wait_audio || exit 1
wait_sink || exit 1

seen=""
started=0

for kbd in /dev/input/by-id/*-event-kbd /dev/input/by-id/*-event-mouse \
    /dev/input/by-path/*-event-kbd /dev/input/by-path/*-event-mouse; do
    [ -e "$kbd" ] || continue

    real=$(readlink -f "$kbd")
    case " $seen " in *" $real "*) continue ;; esac
    seen="$seen $real"

    name=$(device_name "$kbd")
    [ -n "$name" ] || continue
    case "$name" in
        *[Tt]ouchpad*|*[Ss]tylus*|[Ee]LAN*|[Ss]ynaptics*|[Ww]acom*|\
        *[Mm]ouse*|*[Cc]onsumer*|*[Ss]ystem*|*[Cc]ontrol*|*[Hh]otkey*|\
        *[Vv]irtual*|*[Pp]ower*|*[Bb]utton*|*[Ss]witch*|*[Ll]id*) continue ;;
    esac

    wait_device "$kbd" || continue

    wayvibes --device-name "$name" "$SOUNDPACK" -v 0.5 &
    started=$((started + 1))
done

[ "$started" -eq 0 ] && exit 1

wait
