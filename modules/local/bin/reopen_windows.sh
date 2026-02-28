#!/bin/sh

hyprctl notify -1 1000 "rgb(ff1ea3)" "Recovering the group."

cd Documents/slides

echo "🌟 Hey there! Let's choose a group to open! 🌟"
input_file=$(ls | fzf --cycle) && [ -n "$input_file" ] || {
    input_file="DEFAULT.txt"
    echo "Choose from the default path $input_file."
}

hyprctl dispatch togglegroup
while IFS= read -r line; do
    setsid $line &
    sleep 1
done < "$input_file"
