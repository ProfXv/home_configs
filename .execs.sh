# Set programs that you use
te=kitty
fe="$te ranger"
se="$te nvim"
rm="$te btop"
wb="firefox --new-window"

pkill wofi || eval hyprctl dispatch `grep ^bind .config/hypr/* | wofi -d | awk -F, '{print $3 $4}'`
