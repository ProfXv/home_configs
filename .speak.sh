#!/bin/bash

cd .asr/bin
words=$(./iat_online_record_sample)

if [ "$1" = "simple" ]; then
    wl-copy -p "$words"
    ydotool click 0xC2
elif [ "$1" = "complex" ]; then
    echo "$words" | sed "s/这个/$(wl-paste -p)/" > /tmp/words
    wl-copy -p < /tmp/words
    hyprctl notify -1 2000 "rgb(ffffa3)" "Transformation Completed."
fi
