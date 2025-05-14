#!/bin/bash

# Wait until checkupdates returns a result (retry for up to 30 seconds)
timeout=30
elapsed=0
while [ "$elapsed" -lt "$timeout" ]; do
    if output=$(checkupdates 2>/dev/null); then
        break
    fi
    sleep 1
    elapsed=$((elapsed + 1))
done

# Fallback if it still failed
if [ -z "$output" ]; then
    echo " Update check failed"
    exit 1
fi

count=$(echo "$output" | wc -l)

if [ "$count" -eq 0 ]; then
    echo " Up to date"
elif [ "$count" -eq 1 ]; then
    echo " 1 update"
else
    echo " $count updates"
fi
