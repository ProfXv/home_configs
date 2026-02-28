#!/usr/bin/env bash

info=`hyprctl activewindow -j`
workspace=`echo $info | jq -r .workspace.name`
class=`echo $info | jq -r .class`

text=$(wl-paste -p)
sqlite3 ~/.log.db "INSERT INTO focus VALUES (NULL, datetime('now', 'localtime'), '$1', '$workspace', '$class', '$text')"
hyprctl notify -1 1000 "rgb(ff1ea3)" $1
case $1 in
    paste)
	    echo $text > /tmp/clipboard
        mkdir -p ~/Documents/notes
        script=Documents/notes/`date +%s`_"$class".md
        echo -e "$text\n\n---\n" > "$script"
        alacritty -e nvim "$script"
        ;;
    type)
        sleep 1; ydotool type "$text"
        ;;
    copy)
        wl-copy -p < "$text"
        ;;
    open)
        eval xdg-open $text
        ;;
    generate)
        alacritty -e claude "$text"
        ;;
    execute)
        script=/tmp/script
        wl-paste -p > $script
        chmod +x $script
        alacritty --hold -e sh -c "if ! head -1 $script | grep -q '^#!'; then
            echo 'Please enter interpreter (e.g. sh, python, wolframscript):'
            read interpreter
        fi
        \$interpreter $script"
        ;;
    *)
        echo INVALID OPTION: $1
        ;;
esac
