#!/bin/bash

log_path=~/.daily/speak_count
echo $(( $(cat $log_path) + 1 )) > $log_path
hyprctl notify -1 1000 "rgb(ff1ea3)" "Start Recognition."
cd ~/.asr/bin
words=$(./iat_online_record_sample)

if [ -n "$words" ]; then
    echo -e `date +'%F %T'`\\t$words >> ~/.words.txt
    case "$1" in
        "simple")
            wl-copy "$words"
            ydotool key 29:1 47:1 29:0 47:0
            ;;
        "complex")
            echo "$words" | sed "s/这个/$(wl-paste -p)/" >> /tmp/words
            wl-copy -p < /tmp/words
            ;;
    esac
    hyprctl notify -1 2000 "rgb(ffffa3)" "End Recognition."
fi
