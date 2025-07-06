#!/bin/sh

unicode=`kitten unicode-input`
windows=`hyprctl activeworkspace -j | jq .windows`
if [ $windows != 1 ]; then hyprctl dispatch focuscurrentorlast; fi
wtype $unicode
