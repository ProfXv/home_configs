#!/bin/sh

cliphist list | fzf | cliphist decode | wl-copy
hyprctl dispatch focuscurrentorlast
wtype `wl-paste`
