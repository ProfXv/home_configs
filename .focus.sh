info=`hyprctl activewindow -j`
workspace=`echo $info | jq .workspace.name | sed 's/"//g'`
class=`echo $info | jq .class | sed 's/"//g'`
title=`echo $info | jq .title | sed 's/"//g'`

echo -e "$(date '+%F %T')\t$1\t$workspace\t$class\t$title\t`wl-paste -p`" >> ~/.focus_log
case $1 in
    note)
        wl-paste -pn > Documents/Obsidian/速记/`date +%s`_"$workspace"_"$class"_"$title".md
        ;;
    search)
        google-chrome-stable --new-window "https://www.google.com/search?q=`wl-paste -p`"
        ;;
    generate)
        kitty --hold python .service/generate.py -m "`wl-paste -p`"
        ;;
    ask)
        kitty --hold python .service/generate.py -p -m "`wl-paste -p`"
        ;;
    *)
        echo INVALID OPTION: $1
        ;;
esac
