#!/bin/bash

hyprctl notify -1 1000 "rgb(ff1ea3)" "Recovering the group."

cd Documents/slides

echo "🌟 Hey there! Let's choose a group to open! 🌟"
input_file=$(ls | fzf) && [ -n "$input_file" ] || {
    input_file="DEFAULT.txt"
    echo "Choose from the default path $input_file."
}

while IFS= read -r line; do
    sleep 1
    eval "$line" &
done < "$input_file"
