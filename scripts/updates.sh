#!/bin/bash

# Timeout settings
timeout=30
elapsed=0

# Try to get update list from yay
while [ "$elapsed" -lt "$timeout" ]; do
    yay_output=$(yay -Qu 2>/dev/null)
    exit_code=$?

    if [ "$exit_code" -eq 0 ] || [ "$exit_code" -eq 1 ]; then
        break
    fi

    sleep 1
    ((elapsed++))
done

# If yay failed entirely
if [ "$exit_code" -ne 0 ] && [ "$exit_code" -ne 1 ]; then
    echo " Could not check updates"
    exit 1
fi

# Filter valid update lines (pkgname version)
valid_updates=$(printf "%s" "$yay_output" | grep -E '^[a-zA-Z0-9._+-]+ [^ ]+$')

# Count updates only if there is output
if [ -n "$valid_updates" ]; then
    official_count=$(printf "%s" "$valid_updates" | grep -v '/' | grep -c '^')
    aur_count=$(printf "%s" "$valid_updates" | grep '/' | grep -c '^')
else
    official_count=0
    aur_count=0
fi

total=$((official_count + aur_count))

# Waybar output
if [ "$total" -eq 0 ]; then
    echo " Up to date"
else
    echo " $total updates ($official_count + $aur_count AUR)"
fi
