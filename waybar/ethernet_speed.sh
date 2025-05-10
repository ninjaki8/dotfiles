#!/bin/bash

INTERFACE=$(ip route | awk '/default/ {print $5}')
SPEED=$(ethtool "$INTERFACE" 2>/dev/null | awk -F': ' '/Speed:/ {print $2}')

echo "$SPEED"

