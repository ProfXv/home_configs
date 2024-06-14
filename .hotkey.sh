#!/bin/bash

echo -e "$(date +%s)\t$1\t$2" >> ~/.hotkey_log
hyprctl dispatch "$2"
hyprctl notify -1 1000 "rgb(ff1ea3)" "$1: $2"
