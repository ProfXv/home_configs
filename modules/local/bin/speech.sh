#!/bin/sh

if [ -n "$1" ] && [ "$1" -eq "$1" ] 2>/dev/null; then
    content=$(sqlite3 ~/.log.db "SELECT content FROM speech WHERE id > (SELECT MAX(id) FROM speech) - 10 AND id % 10 = $1;")
else
    content=$(sqlite3 ~/.log.db "SELECT * FROM speech;" | fzf -m --tac | cut -d '|' -f 5 || exit)
    windows=`hyprctl activeworkspace -j | jq .windows`
    if [ $windows != 1 ]; then hyprctl dispatch focuscurrentorlast; fi
fi

wl-copy "$content"
hyprctl dispatch sendshortcut CTRL, v,
kill $KITTY_PID
