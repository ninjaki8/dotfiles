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

color=$(grim -g "$selection" -t ppm - \
    | magick - -format '%[pixel:p{0,0}]' txt:- \
    | tail -n1 | awk '{print $NF}')

[ -z "$color" ] && echo "Failed to extract color." && exit 1

echo -n "$color" | wl-copy

image=$(mktemp /tmp/colorpicker_XXXXXX.png)
magick -size 48x48 xc:"$color" "$image"

notify-send -u low -i "$image" "$color copied to clipboard"

( sleep 10 && rm -f "$image" ) & disown
