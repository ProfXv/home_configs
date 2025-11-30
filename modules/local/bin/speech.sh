#!/bin/sh

if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null; then
    content=$(sqlite3 ~/.log.db "SELECT content FROM speech WHERE id > (SELECT MAX(id) FROM speech) - 10 AND id % 10 = $1;")
else
    content=$(sqlite3 ~/.log.db "SELECT * FROM speech;" | fzf -m --tac | cut -d '|' -f 5)
    windows=`hyprctl activeworkspace -j | jq .windows`
    if [ $windows != 1 ]; then hyprctl dispatch focuscurrentorlast; fi
fi

[ -n "$content" ] && if [ "$2" = -c ]; then
    qwen_terminal='kitten @ --to unix:/tmp/qwen'
    hyprctl dispatch togglespecialworkspace 
    eval $qwen_terminal send-text "$content"
    eval $qwen_terminal send-key Return
    current_text=$(eval $qwen_terminal get-text)
    while [ "$previous_text" != "$current_text" ]; do
        sleep 1
        previous_text=$current_text
        current_text=$(eval $qwen_terminal get-text)
    done
    hyprctl dispatch togglespecialworkspace 
else
    wl-copy "$content"
    hyprctl dispatch sendshortcut CTRL, v,
    kill $KITTY_PID
fi
