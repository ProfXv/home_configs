#!/bin/sh

hyprctl notify -1 1000 "rgb(ff1ea3)" "Saving the group."
path=Documents/slides
mkdir -p $path
cd $path

echo "🌟 Hey there! Let's give your group a fresh new name! 🌟"
read -p "Enter the cool new name (or press Enter to select from existing ones): " output_file
[ -n "$output_file" ] || output_file=$(ls | fzf) && [ -n "$output_file" ] || {
    output_file="DEFAULT.txt"
    echo "Saving to the default path $output_file."
}

hyprctl dispatch focuscurrentorlast
rm $output_file
for addr in $(hyprctl activewindow -j | jq -r '.grouped[]'); do
    pid=$(hyprctl clients -j | jq -r '.[] | select(.address == "'$addr'") | .pid')
    class=$(hyprctl clients -j | jq -r '.[] | select(.address == "'$addr'") | .class')
    hyprctl dispatch focuswindow address:$addr
    if [[ "$class" == "nyxt" ]]; then
        hyprctl dispatch sendshortcut CTRL, l,
        hyprctl dispatch sendshortcut CTRL, c,
        url=$(wl-paste)
        echo "xdg-open $url" >> "$output_file"
    else
        process_cmd=$(ps -p $pid -o args=)
        echo "$process_cmd" >> "$output_file"
    fi
done
