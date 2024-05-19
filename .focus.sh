class=`hyprctl activewindow -j | jq '.class'`
title=`hyprctl activewindow -j | jq '.title'`

if [ "$class" != '"kitty"' ]; then
    ydotool key 133:1 133:0
# else
    # ydotool key 29:1 42:1 46:1 46:0 42:0 29:0
    # ydotool key 29 42 46
fi
sleep 1

case $1 in
    note)
        wl-paste > Documents/Obsidian/速记/$(date +%F_%T)_$title.md
        ;;
    search)
        google-chrome-stable --new-window "https://www.google.com/search?q=`wl-paste`"
        ;;
    generate)
        kitty --hold python .service/chat.py
        ;;
    *)
        echo INVALID OPTION: $1
        ;;
esac
