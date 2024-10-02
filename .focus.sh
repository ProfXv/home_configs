#!/bin/bash

info=`hyprctl activewindow -j`
workspace=`echo $info | jq .workspace.name | sed 's/"//g'`
class=`echo $info | jq .class | sed 's/"//g'`
title=`echo $info | jq .title | sed 's/"//g'`

text=$(xclip -o)
echo -e "$(date '+%F %T')\t$1\t$workspace\t$class\t$title\t$text" >> ~/.focus_log
hyprctl notify -1 1000 "rgb(ff1ea3)" $1
case $1 in
    paste)
	    echo $text > /tmp/clipboard
        script=Documents/Obsidian/速记/`date +%s`_"$workspace"_"$class"_"$title".md
        echo -e "$text\n\n---\n" > "$script"
        kitty nvim "$script"
        ;;
    type)
        sleep 1; ydotool type "$text"
        ;;
    copy)
        wl-copy -p < "$text"
        ;;
    search) # 其实应该合并到打开
        grep -E '^(https?://)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*/?$' <<< "$text"
        if [ $? -eq 0 ]; then query="$text"; else query="https://www.google.com/search?q=$text"; fi
	    firefox --new-window "$query"
        ;;
    open)
        if [ ! -f $text ]; then touch $text; fi
        if [[ $(stat -c '%U' "$text") == "root" ]]; then sudo=sudo; fi
        kitty $sudo rifle $text
        ;;
    generate)
        kitty --listen-on unix:@$$ &
        sleep 1
        kitten @ --to unix:@$$ send-text "$text"\\n
        ;;
    *)
        echo INVALID OPTION: $1
        ;;
esac
