#!/bin/bash

cd .sites
sites=`ls | fzf`
site=`cat $sites | fzf`
if [ -n "$site" ]; then
    nohup rifle $site &
else
    # assuming in a browser
    hyprctl dispatch focuscurrentorlast
    ydotool key 29:1 38:1 38:0 29:0 && sleep .5
    text=$(xclip -o)
    curl "$text" && echo $text >> $sites
fi
kill $KITTY_PID
