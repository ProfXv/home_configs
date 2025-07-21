#!/bin/zsh

log_path=~/.daily/speak_count
echo $(( $(cat $log_path) + 1 )) > $log_path
hyprctl notify -1 1000 "rgb(ff1ea3)" "Just tell me what you wanna do!"
gemini_terminal='kitten @ --to unix:/tmp/gemini'
text=`ASRCaption`
if [ -n "$text" ]; then
    eval $gemini_terminal send-text $text
    while eval $gemini_terminal get-text | grep -q '>   Type your message'; do continue; done
    eval $gemini_terminal send-key Return
fi
