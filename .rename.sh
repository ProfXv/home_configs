#!/bin/bash

old_name=`hyprctl activewindow -j | jq .workspace.id`
echo "🌟 Hey there! Let's give your workspace a fresh new name! 🌟"
read -p "Enter the cool new name for this workspace: " new_name
hyprctl dispatch renameworkspace $old_name $new_name
