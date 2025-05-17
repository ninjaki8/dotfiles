#!/bin/bash

NWG_SETTINGS="$HOME/.local/share/nwg-look/gsettings"

if [[ "$1" != "light" && "$1" != "dark" ]]; then
    echo "Usage: $0 [light|dark]"
    exit 1
fi

if [[ "$1" == "light" ]]; then
    new_theme="Adwaita"
else
    new_theme="Adwaita-dark"
fi

if [[ ! -f "$NWG_SETTINGS" ]]; then
    echo "Error: $NWG_SETTINGS does not exist. Please run nwg-look GUI once to generate it."
    exit 1
fi

if grep -q '^gtk-theme=' "$NWG_SETTINGS"; then
    sed -i "s/^gtk-theme=.*/gtk-theme=$new_theme/" "$NWG_SETTINGS"
else
    echo "gtk-theme=$new_theme" >> "$NWG_SETTINGS"
fi

nwg-look -a

echo "Theme set to: $new_theme and applied via nwg-look"
