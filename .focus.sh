#!/bin/bash

info=`hyprctl activewindow -j`
workspace=`echo $info | jq .workspace.name | sed 's/"//g'`
class=`echo $info | jq .class | sed 's/"//g'`
title=`echo $info | jq .title | sed 's/"//g'`

text=$(xclip -o)
echo -e "$(date '+%F %T')\t$1\t$workspace\t$class\t$title\t$text" >> ~/.focus_log
case $1 in
    paste)
	echo $text > /tmp/clipboard
        echo $text > Documents/Obsidian/速记/`date +%s`_"$workspace"_"$class"_"$title".md
        ;;
    copy)
        wl-copy -p < "$text"
        ;;
    search)
        grep -E '^(https?://)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*/?$' <<< "$text"
        if [ $? -eq 0 ]; then query="$text"; else query="https://www.google.com/search?q=$text"; fi
        google-chrome-stable --new-window "$query"
        ;;
    open)
        if [[ $(stat -c '%U' "$text") == "root" ]]; then sudo=sudo; fi
        kitty $sudo xdg-open "$text"
        ;;
    generate)
        kitty --hold python .service/generate.py -m "$text"
        ;;
    ask)
        kitty --hold python .service/generate.py -p -m "$text"
        ;;
    *)
        echo INVALID OPTION: $1
        ;;
esac
