#!/bin/bash

# Function to check if the given name matches any of the allowed app names
check_app() {
  local input="$1"
  local apps=("kitty" "hypr" "rofi" "scripts" "wallpapers" "waybar" "wlogout")

  # Loop through each app name and compare with the input
  for app in "${apps[@]}"; do
    if [[ "$app" == "$input" ]]; then
      return 0  # Match found (true)
    fi
  done

  return 1  # No match found (false)
}

# Set the current working directory as the base for dotfiles
SCRIPT_DIR="$(pwd)"

# Set the target configuration directory (usually where app configs live)
CONFIG_DIR="$HOME/.config"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'  # No color (reset)

# Header for output
echo -e "${YELLOW}==================== Starting Symlink Creation ====================${NC}"

# Loop through each file or folder in the dotfiles directory
for dir in "$SCRIPT_DIR"/*; do
  # Extract just the name of the file/folder (without the path)
  name=$(basename "$dir")

  # Check if the name matches one of the apps in the list
  if check_app "$name"; then
    # Define the target path in the ~/.config directory
    target="$CONFIG_DIR/$name"

    # If the target already exists (either file, folder, or symlink), remove it
    if [ -e "$target" ] || [ -L "$target" ]; then
      rm -rf "$target"
    fi

    # Create a symbolic link from the dotfiles folder to the ~/.config directory
    ln -s "$dir" "$target"
    echo -e "${GREEN}[Linked]${NC} $name -> $target"
  fi
done

# Special case: link .bashrc to $HOME/.bashrc
BASHRC="$SCRIPT_DIR/.bashrc"
if [ -e "$BASHRC" ]; then
    if [ -e "$HOME/.bashrc" ] || [ -L "$HOME/.bashrc" ]; then
        rm -rf "$HOME/.bashrc"
    fi
    ln -s "$BASHRC" "$HOME/.bashrc"
    echo -e "${GREEN}[Linked]${NC} .bashrc -> $HOME/.bashrc"
fi