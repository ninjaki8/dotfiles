#!/bin/bash

# Run checkupdates from pacman-contrib
if ! command -v checkupdates &>/dev/null; then
  echo "󰏖 ??"  # Indicate error or unknown count
  exit 1
fi

# Count the available updates
update_count=$(checkupdates 2>/dev/null | wc -l)

# Pad with leading zero if less than 10 using printf
update_count=$(printf "%02d" "$update_count")

echo "󰏖 $update_count"
