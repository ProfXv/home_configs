#!/bin/bash

old_id=$(hyprctl activewindow -j | jq .workspace.id)
old_name=$(hyprctl activewindow -j | jq -r .workspace.name)
echo "🌟 Hey there! Let's give your workspace a fresh new name! 🌟"
read -p "Enter the cool new name (or press Enter to select from existing ones): " new_name

[ -n "$new_name" ] || new_name=$(cd ~/Desktop/Projects/ours && ls | fzf) && [ -n "$new_name" ] && {
    hyprctl dispatch renameworkspace $old_id "$new_name"
    cd ~/Desktop/Projects/ours
    [ -d "$old_name" ] && rsync -av "$old_name"/ "$new_name"/ && rm -r "$old_name"
}
