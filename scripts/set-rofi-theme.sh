#!/bin/bash

CONFIG="$HOME/.config/rofi/config.rasi"
LIGHT_THEME="~/.config/rofi/themes/spotlight-light.rasi"
DARK_THEME="~/.config/rofi/themes/spotlight-dark.rasi"

case "$1" in
  light)
    sed -i "s|@theme.*|@theme \"$LIGHT_THEME\"|" "$CONFIG"
    echo "Switched to light theme."
    ;;
  dark)
    sed -i "s|@theme.*|@theme \"$DARK_THEME\"|" "$CONFIG"
    echo "Switched to dark theme."
    ;;
  *)
    echo "Usage: $0 [light|dark]"
    exit 1
    ;;
esac
