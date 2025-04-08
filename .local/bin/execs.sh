#!/bin/bash

operation=$(
    hyprctl binds -j | jq -r '.[] | (
      (if .locked then " " else "" end) +
      (if .mouse then "󰍽 " else "" end) +
      (if .release then "󰕰 " else "" end) +
      (if .repeat then " " else "" end) +
      (if .non_consuming then "⦽ " else "" end) +
      (if .catch_all then "󰚾 " else "" end) +
      "\(.modmask) \(.key) \(.keycode) " +
      (if .has_description then "󰂮 \(.description) " else "" end) +
      "󱊨 \(.dispatcher) \(.arg)"
    )' | fzf --cycle | sed 's/.*󱊨 //'
)

windows=`hyprctl activeworkspace -j | jq .windows`
if [ $windows != 1 ]; then hyprctl dispatch focuscurrentorlast; fi
eval hyprctl dispatch "\"$operation\""
kill $KITTY_PID
