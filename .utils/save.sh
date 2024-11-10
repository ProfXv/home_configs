cd "`~/.utils/path.sh`"
# assuming in a browser
sleep .5
ydotool key -d 100 29:1 38:1 38:0 46:1 46:0 29:0 && sleep .5
text=$(xclip -o)
curl "$text" && echo $text >> Sites.txt
