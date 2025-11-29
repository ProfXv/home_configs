#!/usr/bin/env zsh

log_path=~/.daily/speak_count
echo $(( $(cat $log_path) + 1 )) > $log_path
qwen_terminal='kitten @ --to unix:/tmp/qwen'

hyprctl dispatch togglespecialworkspace 
ASRCaption simple
sleep 1
eval $qwen_terminal send-key Return
current_text=$(eval $qwen_terminal get-text)
while [ "$previous_text" != "$current_text" ]; do
    sleep 1
    previous_text=$current_text
    current_text=$(eval $qwen_terminal get-text)
done
hyprctl dispatch togglespecialworkspace 
