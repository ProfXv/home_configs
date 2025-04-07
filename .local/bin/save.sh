# assuming in a browser
sleep .5
ydotool key -d 100 29:1 38:1 38:0 46:1 46:0 29:0 && sleep .5
hyprctl notify -1 1000 "rgb(ff1ea3)" "Give a name if you want."
name=`~/.asr/bin/iat_online_record_sample | sed 's/.$//'`
hyprctl notify -1 1000 "rgb(ff1ea3)" "Name already given."
text=$(xclip -o)
curl "$text" && echo -e $name\\t$text >> Sites.txt
