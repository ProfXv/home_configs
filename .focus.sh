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
        kitty rifle "$script"
        ;;
    type)
        sleep 1; ydotool type "$text"
        ;;
    copy)
        wl-copy -p < "$text"
        ;;
    open)
        if [ -f $text ]; then
            if [[ $(stat -c '%U' "$text") == "root" ]]; then sudo=sudo; fi
            kitty $sudo rifle $text
        else
            grep -E '^(https?://)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*/?$' <<< "$text" &&
            query="$text" || query="https://www.google.com/search?q=$text"
            rifle "$query"
        fi
        ;;
    generate)
        kitty --listen-on unix:@$$ &
        sleep 1
        kitten @ --to unix:@$$ send-text "$text"\\n
        ;;
    execute)
        script=/tmp/script
        xclip -o > $script
        chmod +x $script
        kitty --hold sh -c "if ! head -1 $script | grep -q '^#!'; then
            echo 'Please enter interpreter (e.g. sh, python, wolframscript):'
            read interpreter
        fi
        \$interpreter $script"
        ;;
    *)
        echo INVALID OPTION: $1
        ;;
esac
