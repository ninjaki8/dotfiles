#!/bin/bash

# Wait up to 30s for yay to succeed (in case system is still initializing)
timeout=30
elapsed=0
updates_ready=false

while [ "$elapsed" -lt "$timeout" ]; do
    yay_output=$(yay -Qu 2>/dev/null)
    exit_code=$?

    if [ "$exit_code" -eq 0 ] || [ "$exit_code" -eq 1 ]; then
        updates_ready=true
        break
    fi

    sleep 1
    elapsed=$((elapsed + 1))
done

if ! $updates_ready; then
    echo " Could not check updates"
    exit 1
fi

# Separate official and AUR updates based on `/` presence
official_count=$(echo "$yay_output" | grep -v '/' | wc -l)
aur_count=$(echo "$yay_output" | grep '/' | wc -l)
total=$((official_count + aur_count))

# Output for Waybar
if [ "$total" -eq 0 ]; then
    echo " Up to date"
else
    echo " $total updates ($official_count + $aur_count AUR)"
fi
