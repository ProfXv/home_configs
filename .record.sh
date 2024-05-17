ydotool key 133:1 133:0
title=`hyprctl activewindow -j | jq '.title'`
sleep 1
wl-paste > Documents/Obsidian/速记/`date +%F_%T`_"$title".md
