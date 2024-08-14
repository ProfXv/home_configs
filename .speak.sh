#!/bin/bash

hyprctl notify -1 1000 "rgb(ff1ea3)" "Start Recognition."
cd .asr/bin
words=$(./iat_online_record_sample)

if [ -n "$words" ]; then
    echo -e `date +'%F %T'`\\t$words >> ~/.words.txt
    if [ "$1" = "simple" ]; then
        wl-copy -p "$words"
        ydotool click 0xC2
    elif [ "$1" = "complex" ]; then
        echo "$words" | sed "s/这个/$(wl-paste -p)/" > /tmp/words
        wl-copy -p < /tmp/words
    fi
    hyprctl notify -1 2000 "rgb(ffffa3)" "End Recognition."
fi
