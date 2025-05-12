#!/bin/bash

sysmenu=$(printf "󰐥  Power Off\n󰜉  Reboot\n󰈆  Log Out" | rofi -dmenu -p "System Menu")

case "$sysmenu" in
    "󰐥  Power Off") systemctl poweroff ;;
    "󰜉  Reboot") systemctl reboot ;;
    "󰈆  Log Out") hyprctl dispatch exit ;;
esac

