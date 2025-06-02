#!/bin/bash

MONITOR=0
margin="500px"

# Execute wlogout with the determined margin
# Run wlogout with:
# -b 4 buttons per row
# -m px margin around the window
# -n no span accross monitors
# -P set primary monitor (hyprctl monitor id 0-x)
wlogout -b 4 -n -P "$MONITOR" -m "$margin"
