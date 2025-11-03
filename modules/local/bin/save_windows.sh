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
        ydotool key 29:1 38:1 38:0 29:0  # Ctrl+L
        sleep 0.5
        ydotool key 29:1 46:1 46:0 29:0  # Ctrl+C
        sleep 0.5
        url=$(wl-paste)
        echo "nyxt -S $url" >> "$output_file"
    else
        process_cmd=$(ps -p $pid -o args=)
        echo "$process_cmd" >> "$output_file"
    fi
done
