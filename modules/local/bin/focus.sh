#!/usr/bin/env bash

info=`hyprctl activewindow -j`
workspace=`echo $info | jq -r .workspace.name`
class=`echo $info | jq -r .class`

text=$(wl-paste -p)
echo -e "$(date '+%F %T')\t$1\t$workspace\t$class\t\t$text" >> ~/.focus_log
hyprctl notify -1 1000 "rgb(ff1ea3)" $1
case $1 in
    paste)
	    echo $text > /tmp/clipboard
        mkdir -p ~/Documents/notes
        script=Documents/notes/`date +%s`_"$class".md
        echo -e "$text\n\n---\n" > "$script"
        kitty nvim "$script"
        ;;
    type)
        sleep 1; ydotool type "$text"
        ;;
    copy)
        wl-copy -p < "$text"
        ;;
    open)
        if [ -f $text ]; then
            if [[ $(stat -c '%U' $text) == "root" ]]; then sudo=sudo; fi
            kitty $sudo xdg-open $text
        else
            grep -E '^(https?://)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*/?$' <<< "$text" &&
            query="$text" || query="https://www.google.com/search?q=$text"
            xdg-open "$query"
        fi
        ;;
    generate)
        kitty gemini --allowed-mcp-server-names -m gemini-2.5-flash -i "$text"
        ;;
    execute)
        script=/tmp/script
        wl-paste -p > $script
        chmod +x $script
        source ~/.python/bin/activate
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
