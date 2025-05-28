#!/bin/bash

# Kill existing watchers to avoid duplicates
pkill -f "wl-paste --watch"
pkill -f "wl-paste --primary --watch"

# Start watcher for regular clipboard (Ctrl+C)
wl-paste --watch cliphist store &

# Start watcher for primary selection (mouse highlight)
wl-paste --primary --watch cliphist store &

# Mirror regular clipboard into primary (so middle-click in Kitty works after copying)
wl-paste --watch wl-copy --primary &
