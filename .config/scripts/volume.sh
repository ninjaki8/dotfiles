#!/bin/bash

# Usage:
#   ./volume.sh <integer>  # e.g., 5 or -5 to change volume
#   ./volume.sh mute       # to toggle mute

usage() {
    echo "Usage: $0 <integer | mute>"
    echo "  $0  5     # Increase volume by 5%"
    echo "  $0 -5     # Decrease volume by 5%"
    echo "  $0 mute   # Toggle mute"
    exit 1
}

# Check for valid input
if [[ $# -ne 1 ]]; then
    usage
fi

if [[ "$1" == "mute" ]]; then
    # Toggle mute
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
else
    # Validate integer argument
    if ! [[ $1 =~ ^-?[0-9]+$ ]]; then
        usage
    fi

    # Get current volume
    vol_decimal=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')

    # Cap at 100%
    if (( $1 >= 0 )); then
        at_max=$(awk "BEGIN {print ($vol_decimal >= 1.0) ? 1 : 0}")
        if [[ "$at_max" -eq 0 ]]; then
            wpctl set-volume @DEFAULT_AUDIO_SINK@ "${1}%+"
        fi
    else
        wpctl set-volume @DEFAULT_AUDIO_SINK@ "${1#-}%-"
    fi
fi

# Get updated volume and mute state
vol_output=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
vol_decimal=$(echo "$vol_output" | awk '{print $2}')
new_volume=$(awk "BEGIN {printf \"%.0f\", $vol_decimal * 100}")
muted=$(echo "$vol_output" | grep -q MUTED && echo "(Muted)" || echo "")

# Get audio server
audio_server=$(pactl info 2>/dev/null | grep "Server Name" | cut -d ':' -f2- | xargs)

# Show notification
notify-send -i audio-speaker-left-side-testing "Volume: $new_volume% $muted" "$audio_server" -h string:x-dunst-stack-tag:volume
