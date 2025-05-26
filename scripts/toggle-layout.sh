#!/bin/bash

# User input
action="$1"

# Validate allowed actions
if [[ "$action" != "layout" && "$action" != "toggle" ]]; then
    echo "Invalid argument: $action"
    echo "Usage: $0 [layout|toggle]"
    exit 1
fi

# Get current layout
current_layout=$(hyprctl getoption general:layout | awk 'NR==1{print $2}')

# If action is "layout", just output current layout JSON
if [[ "$action" == "layout" ]]; then
    echo "{\"text\": \"$current_layout\", \"alt\": \"$current_layout\", \"tooltip\": \"Hyprland layout: $current_layout\"}"
    exit 0
fi

# Otherwise, perform toggle
if [[ "$current_layout" == "dwindle" ]]; then
    hyprctl keyword general:layout "master" > /dev/null
    notify-send -i preferences-system-windows "Hyprland Layout" "Switched to Master layout"
else
    hyprctl keyword general:layout "dwindle" > /dev/null
    notify-send -i preferences-system-windows "Hyprland Layout" "Switched to Dwindle layout"
fi

# Send signal to Waybar to refresh the module (signal 9)
pkill -SIGRTMIN+9 waybar
