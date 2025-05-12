#!/bin/bash

# Set current directory as DOTFILES_DIR and the default config directory
DOTFILES_DIR="$(pwd)"
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

# Special case: link .bashrc to $HOME/.bashrc
BASHRC="$DOTFILES_DIR/.bashrc"
if [ -e "$BASHRC" ]; then
    if [ -e "$HOME/.bashrc" ] || [ -L "$HOME/.bashrc" ]; then
        echo "Removing existing $HOME/.bashrc"
        rm -rf "$HOME/.bashrc"
    fi
    ln -s "$BASHRC" "$HOME/.bashrc"
    echo "Linked .bashrc → $HOME/.bashrc"
fi

echo "Done."
