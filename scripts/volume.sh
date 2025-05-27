#!/bin/bash

# Usage: ./volume.sh <integer>
# Example: ./volume.sh  5    # Increase volume by 5%
# Example  ./volume.sh -5    # Decrease volume by 5%


# Function to show usage
usage() {
    echo "Usage: $0 <integer>"
    echo "Example: $0  5    # Increase volume by 5%"
    echo "Example: $0 -5    # Decrease volume by 5%"
    exit 1
}

# Validate argument
if [[ $# -ne 1 || ! $1 =~ ^-?[0-9]+$ ]]; then
    usage
fi

# Change volume
if (( $1 >= 0 )); then
    pamixer -i "$1"
else
    pamixer -d "${1#-}"
fi

# Get new volume
new_volume=$(pamixer --get-volume)

# Get audio server (PulseAudio, PipeWire, etc.)
audio_server=$(pactl info 2>/dev/null | grep "Server Name" | cut -d ':' -f2- | xargs)

# Send notification
# -a appname
# -h <string> to replace notifications
# title
# body
# -h int:value for progress bar
dunstify -a "Audio" \
    -h string:x-canonical-private-synchronous:audio \
    "Volume: $new_volume%" \
    "$audio_server" \
    -h int:value:"$new_volume"
