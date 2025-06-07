#!/usr/bin/env bash

action=$( echo -e "  Poweroff\n  Reboot\n  Lock\n  Logout" | wofi -i --dmenu --width 400 --height 320 | awk '{print tolower($2)}' )

case $action in
    poweroff)
        systemctl poweroff
    ;;
    reboot)
        systemctl reboot
    ;;
    lock)
        hyprlock
    ;;
    logout)
        uwsm stop
    ;;
esac