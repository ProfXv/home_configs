#!/bin/bash

echo -e "$(date +%s)\t$1\t$2" >> ~/.hotkey_log
case $XDG_CURRENT_DESKTOP in
    Hyprland)
	hyprctl dispatch "$2"
	hyprctl notify -1 1000 "rgb(ff1ea3)" "$1: $2"
        ;;
    *)
        i3-msg "$2"
        ;;
esac
