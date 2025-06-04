#!/bin/bash

set -euo pipefail
shopt -s failglob

old_id=$(hyprctl activewindow -j | jq .workspace.id)
old_name=$(hyprctl activewindow -j | jq -r .workspace.name)
cd ~/Desktop/Projects

echo "🌟 Hey there! Let's give your workspace a fresh new name! 🌟"
[ -d "$old_name" ] && {
    read -p "Enter the cool new name: " new_name
    [ "$old_name" != "$new_name" ] && [ ! -d "$new_name" ] && [ -n "$new_name" ] &&
    echo "󰪹 Moving to our new home..." && hyprctl dispatch renameworkspace $old_id "$new_name" && {
        rsync -av "$old_name"/ "$new_name"/
        rm -r "$old_name"
    } || {
        echo " Given name is empty, the same, or already exists."
        sleep 3
    }
} || {
    read -p "Enter the cool new name (or press Enter to select from existing ones): " new_name
    [ -n "$new_name" ] && mkdir -p "$new_name" || new_name=$(ls -t | fzf) && [ -n "$new_name" ] &&
    hyprctl dispatch renameworkspace $old_id "$new_name"
}
