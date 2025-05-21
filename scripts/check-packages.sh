#!/bin/bash

# Set the path to the package list
PACKAGE_FILE="packages.txt"

# ANSI color codes
GREEN="\033[1;32m"
RED="\033[1;31m"
RESET="\033[0m"

# Check if the package file exists
if [[ ! -f "$PACKAGE_FILE" ]]; then
    echo -e "${RED}Error: $PACKAGE_FILE not found.${RESET}"
    exit 1
fi

echo "Checking installed packages from $PACKAGE_FILE..."

# Check if yay is available
if ! command -v yay &> /dev/null; then
    echo -e "${RED}Warning: 'yay' is not installed. AUR package checks may fail.${RESET}"
fi

while IFS= read -r line || [[ -n "$line" ]]; do
    # Remove comments and empty lines
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

    if [[ "$line" == aur/* ]]; then
        pkg="${line#aur/}"
        if yay -Q "$pkg" &> /dev/null; then
            echo -e "[${GREEN}✔${RESET}] $pkg (AUR) is installed"
        else
            echo -e "[${RED}✘${RESET}] $pkg (AUR) is NOT installed"
        fi
    else
        pkg="$line"
        if pacman -Q "$pkg" &> /dev/null; then
            echo -e "[${GREEN}✔${RESET}] $pkg is installed"
        else
            echo -e "[${RED}✘${RESET}] $pkg is NOT installed"
        fi
    fi
done < "$PACKAGE_FILE"
