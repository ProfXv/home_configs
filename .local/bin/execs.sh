#!/bin/bash

# Set programs that you use
te="source path.sh; kitty"
env="source .python/bin/activate; source path.sh;"
sw="[float; size 960 540]"

operation=$(
    hyprctl binds -j | jq -r '.[] | (
      (if .locked then " " else "" end) +
      (if .mouse then "󰍽 " else "" end) +
      (if .release then "󰕰 " else "" end) +
      (if .repeat then " " else "" end) +
      (if .non_consuming then "⦽ " else "" end) +
      (if .catch_all then "󰚾 " else "" end) +
      "\(.modmask) \(.key) \(.keycode) 󱊨 \(.dispatcher) \(.arg)"
    )' | fzf | sed 's/.*󱊨 //'
)

windows=`hyprctl activeworkspace -j | jq .windows`
if [ $windows != 1 ]; then hyprctl dispatch focuscurrentorlast; fi
eval hyprctl dispatch "\"$operation\""
kill $KITTY_PID
