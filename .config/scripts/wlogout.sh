#!/bin/bash

MONITOR=0

# Ensure hyprctl and jq are available
if ! command -v hyprctl &> /dev/null || ! command -v jq &> /dev/null; then
    echo "Error: This script requires 'hyprctl' and 'jq'."
    exit 1
fi

# Get resolution of the specified monitor
resolution=$(hyprctl monitors -j | jq -r --argjson id "$MONITOR" '.[] | select(.id == $id) | "\(.width)x\(.height)"')

# Check if resolution was found
if [ -z "$resolution" ]; then
    echo "Monitor with ID $MONITOR not found."
    exit 1
fi

# Extract just width for comparison
width=$(cut -d'x' -f1 <<< "$resolution")

# Choose margin (-m value) based on resolution width
margin=""
case "$width" in
    2560)  # 2K (1440p)
        margin="500px"
        ;;
    1920)  # Full HD (1080p)
        margin="350px"
        ;;
    *)
        echo "Unknown resolution width: $width"
        exit 1
        ;;
esac

# Execute wlogout with the determined margin
# Run wlogout with:
# -b 4 buttons per row
# -m px margin around the window
# -n no span accross monitors
# -P set primary monitor (hyprctl monitor id 0-x)
wlogout -b 4 -n -P "$MONITOR" -m "$margin"
