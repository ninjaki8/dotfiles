#!/bin/bash

# USAGE:
# move_workspace.sh next
# move_workspace.sh prev

DIRECTION="$1"  # "next" or "prev"
EXCLUDED_IDS=(11)          # Add any workspaces you want to skip
VALID_IDS=(1 2 3 4 5 6 7 8 9 10)  # Only workspaces on monitor 1

CURRENT_WS=$(hyprctl activeworkspace -j | jq .id)

# Sort workspaces based on direction
if [[ "$DIRECTION" == "next" ]]; then
    for ID in "${VALID_IDS[@]}"; do
        if (( ID > CURRENT_WS )); then
            hyprctl dispatch workspace "$ID"
            exit 0
        fi
    done
elif [[ "$DIRECTION" == "prev" ]]; then
    for (( idx=${#VALID_IDS[@]}-1 ; idx>=0 ; idx-- )) ; do
        ID=${VALID_IDS[idx]}
        if (( ID < CURRENT_WS )); then
            hyprctl dispatch workspace "$ID"
            exit 0
        fi
    done
fi

