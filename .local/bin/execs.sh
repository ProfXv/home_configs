#!/bin/bash

# Set programs that you use
te="source path.sh; kitty"
env="source .python/bin/activate; source path.sh;"
sw="[float; size 960 540]"

#@ later we could use built-in hyprctl binds -j to optimize this script
operation=$(grep ^bind ~/.config/hypr/* | fzf | awk -F, '
    {
        printf "\""
        for (i = 3; i <= NF; i++) {
            gsub(/^ *| *$/, "", $i)
            printf "%s ", $i
        }
        printf "\""
    }
')
windows=`hyprctl activeworkspace -j | jq .windows`
if [ $windows != 1 ]; then hyprctl dispatch focuscurrentorlast; fi
eval hyprctl dispatch $operation
kill $KITTY_PID
