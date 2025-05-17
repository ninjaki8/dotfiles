#!/bin/bash

# Retry yay update check up to 30 times (1s apart)
for i in {1..30}; do
    updates=$(yay -Qu 2>/dev/null)
    result=$?
    # yay returns 0 if updates available, 1 if none, other means error
    if [ "$result" -eq 0 ] || [ "$result" -eq 1 ]; then
        break
    fi
    sleep 1
done

# If after retries result is error, show failure
if [ "$result" -ne 0 ] && [ "$result" -ne 1 ]; then
    echo " yay failed"
    exit 1
fi

# Count lines that look like package updates (non-empty lines)
count=$(echo "$updates" | grep -c '^\S')

if [ "$count" -gt 0 ]; then
    echo " $count updates"
else
    echo " Up to date"
fi
