#!/bin/bash

CONFIG="$HOME/.config/hypr/hyprland.conf"

# Icons
MOD_ICON=""   # Windows/Mod key
ARROW="→"

# Header
echo "  Hyprland Keybindings"
echo "========================"

# Helper: function to format keybinds by category
print_category() {
  local title=$1
  shift
  echo
  echo "🔹 $title"
  echo "------------------------"
  printf "%-30s %s\n" "$@" | column -t -s "$ARROW"
}

# Extract all binds
binds=$(grep '^bind =' "$CONFIG" | sed 's/^bind = //' | sed 's/,/ → /g')

# Categorize (customize this based on your keybinds!)
window_keys=$(echo "$binds" | grep -E 'killactive|fullscreen|togglefloating')
launch_keys=$(echo "$binds" | grep -E 'kitty|terminal|rofi|wofi|app')
workspace_keys=$(echo "$binds" | grep -E 'workspace|movetoworkspace')
misc_keys=$(echo "$binds" | grep -vE 'killactive|fullscreen|togglefloating|kitty|terminal|rofi|workspace|movetoworkspace|wofi|app')

# Print categories
print_category "Window Management" "$window_keys"
print_category "App Launching" "$launch_keys"
print_category "Workspace Control" "$workspace_keys"
print_category "Other" "$misc_keys"
