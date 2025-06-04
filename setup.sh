#!/bin/bash

#   ____  _____ _____ _   _ ____
#  / ___|| ____|_   _| | | |  _ \
#  \___ \|  _|   | | | | | | |_) |
#   ___) | |___  | | | |_| |  __/
#  |____/|_____| |_|  \___/|_|
#

# -----------------------------------------------------
# INSTALL PACKAGES WITH YAY
# -----------------------------------------------------
echo "# -----------------------------------------------------"
echo "# INSTALLING PACKAGES TXT"
echo "# -----------------------------------------------------"

if ! command -v yay >/dev/null 2>&1; then
    echo "yay is not installed, please install it before running this script"
    exit 1
fi

if [[ ! -f "packages.txt" ]]; then
    echo "Error: packages.txt not found"
    exit 1
fi

if [[ ! -s "packages.txt" ]]; then
    echo "packages.txt is empty"
    exit 0
fi

readarray -t PACKAGES < <(grep -vE '^\s*#|^\s*$' packages.txt)
TOTAL=${#PACKAGES[@]}
CURRENT=1

yay -Sy --noconfirm --quiet

for pkg in "${PACKAGES[@]}"; do
    echo "[${CURRENT}/${TOTAL}] Installing: $pkg"
    
    if yay -Q "$pkg" &>/dev/null; then
        echo "✓ Already installed: $pkg"
        elif yay -Ss "^$pkg$" &>/dev/null; then
        if yay -S --noconfirm --needed --quiet "$pkg" &>/dev/null; then
            echo "✓ Installed: $pkg"
        else
            echo "✗ Failed: $pkg"
        fi
    else
        echo "✗ Not found: $pkg"
    fi
    
    ((CURRENT++))
    echo
done


echo "# -----------------------------------------------------"
echo "# INSTALLING APPLICATION CONFIGURATIONS"
echo "# -----------------------------------------------------"

# Allowed application config directories
apps=("foot" "hypr" "wofi" "scripts" "waybar" "mako" "uwsm")

SCRIPT_DIR="$HOME/dotfiles/.config"
CONFIG_DIR="$HOME/.config"

for dir in "$SCRIPT_DIR"/*; do
    name=$(basename "$dir")
    
    # Copy greetd to /etc
    if [[ "$name" == "greetd" ]]; then
        sudo cp -r "$dir" /etc
        echo "Copied: $name -> /etc/greetd"
        continue
    fi
    
    # Create symlinks to .config
    for app in "${apps[@]}"; do
        if [[ "$app" == "$name" ]]; then
            target="$CONFIG_DIR/$name"
            [ -e "$target" ] || [ -L "$target" ] && rm -rf "$target"
            ln -s "$dir" "$target"
            echo "Linked: $name -> $target"
            break
        fi
    done
done

echo
echo "# -----------------------------------------------------"
echo "# MODIFYING BASHRC"
echo "# -----------------------------------------------------"

if ! grep -q 'fastfetch --logo small -s break:os:kernel:host:uptime:shell' ~/.bashrc; then
    {
        echo 'fastfetch --logo small -s break:os:kernel:host:uptime:shell'
        echo 'printf "\n"'
    } >> ~/.bashrc
else
    echo "fastfetch lines already in .bashrc"
fi

echo
echo "# -----------------------------------------------------"
echo "# CREATE VSCODE WAYLAND SHORTCUT"
echo "# -----------------------------------------------------"

# Define paths
SYSTEM_DESKTOP_FILE="/usr/share/applications/code.desktop"
USER_DESKTOP_DIR="$HOME/.local/share/applications"
USER_DESKTOP_FILE="$USER_DESKTOP_DIR/code.desktop"

# Check if the system desktop file exists
if [ ! -f "$SYSTEM_DESKTOP_FILE" ]; then
  echo "Error: System desktop file '$SYSTEM_DESKTOP_FILE' not found."
  exit 1
fi

# Ensure the user applications directory exists
mkdir -p "$USER_DESKTOP_DIR"

# Copy the system .desktop file to the user directory
cp "$SYSTEM_DESKTOP_FILE" "$USER_DESKTOP_FILE"

# Modify the Exec line to include Wayland flags
sed -i 's|^Exec=.*|Exec=/usr/bin/code --ozone-platform=wayland %F|' "$USER_DESKTOP_FILE"

# Modify the Name to indicate Wayland
sed -i 's|^Name=.*|Name=Visual Studio Code (Wayland)|' "$USER_DESKTOP_FILE"

echo "VSCode .desktop file has been updated to launch with Wayland support."