#!/usr/bin/env bash
set -euo pipefail

deps=(grim slurp magick wl-copy notify-send)
for cmd in "${deps[@]}"; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "Error: '$cmd' is required but not installed." >&2
        exit 1
    }
done

selection=$(slurp -b 1B1F2800 -p)
[ -z "$selection" ] && echo "Selection cancelled." && exit 1

# Extract color and convert to hex format
srgb_color=$(grim -g "$selection" -t ppm - \
    | magick - -format '%[pixel:p{0,0}]' txt:- \
    | tail -n1 | awk '{print $NF}')

[ -z "$srgb_color" ] && echo "Failed to extract color." && exit 1

# Convert srgb(r,g,b) to hex
color=$(echo "$srgb_color" | sed -n 's/srgb(\([0-9]*\),\([0-9]*\),\([0-9]*\))/\1 \2 \3/p' | \
    awk '{printf "#%02x%02x%02x\n", $1, $2, $3}')

echo -n "$color" | wl-copy

image=$(mktemp /tmp/colorpicker_XXXXXX.png)
magick -size 48x48 xc:"$color" "$image"
notify-send -u low -i "$image" "$color copied to clipboard"

( sleep 10 && rm -f "$image" ) & disown