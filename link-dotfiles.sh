#!/bin/bash

# Set your dotfiles and config directories
DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

echo "Linking dotfiles from $DOTFILES_DIR to $CONFIG_DIR..."

# Loop through each folder or file in the dotfiles directory
for dir in "$DOTFILES_DIR"/*; do
    name=$(basename "$dir")

    # Skip this script, README.md, wallpapers, and scripts folders
    if [[ "$name" == "link-dotfiles.sh" || "$name" == "README.md" || "$name" == "wallpapers" || "$name" == "scripts" ]]; then
        continue
    fi

    target="$CONFIG_DIR/$name"

    # If target exists, remove it (careful!)
    if [ -e "$target" ] || [ -L "$target" ]; then
        echo "Removing existing $target"
        rm -rf "$target"
    fi

    # Create symlink
    ln -s "$dir" "$target"
    echo "Linked $name → $target"
done

echo "Done."
