#!/bin/bash

# Sleep 2s (waybar startup)
sleep 2

# Check for available updates and count the number of lines (packages)
count=$(pacman -Qu | wc -l)

if [ "$count" -eq 0 ]; then
    echo " Up to date"
elif [ "$count" -eq 1 ]; then
    echo " 1 update"
else
    echo " $count updates"
fi