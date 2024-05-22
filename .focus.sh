info=`hyprctl activewindow -j`
workspace=`echo $info | jq .workspace.name | sed 's/"//g'`
class=`echo $info | jq .class | sed 's/"//g'`
title=`echo $info | jq .title | sed 's/"//g'`

sleep .5; ydotool key 29:1 46:1 46:0 29:0; sleep .5

echo -e "$(date '+%F %T')\t$1\t$workspace\t$class\t$title\t`wl-paste`" >> ~/.focus_log
case $1 in
    note)
        wl-paste -n > Documents/Obsidian/速记/`date +%s`_"$workspace"_"$class"_"$title".md
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
