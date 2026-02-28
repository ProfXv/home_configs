#!/bin/sh

c=false
k=false

if [ "$1" = -c ]; then
    c=true
    shift
elif [ "$2" = -c ]; then
    c=true
    set -- "$1"
fi

if [ -z "$1" ]; then
    content=$(sqlite3 ~/.log.db "SELECT content FROM speech ORDER BY id DESC LIMIT 1;")
elif [ "$1" -eq "$1" ] 2>/dev/null; then
    content=$(sqlite3 ~/.log.db "SELECT content FROM speech WHERE id > (SELECT MAX(id) FROM speech) - 10 AND id % 10 = $1;")
else
    content=$(sqlite3 ~/.log.db "SELECT * FROM speech;" | fzf -m --tac | cut -d '|' -f 5)
    windows=`hyprctl activeworkspace -j | jq .windows`
    if [ $windows != 1 ]; then hyprctl dispatch focuscurrentorlast; fi
    k=true
fi

[ -n "$content" ] && if $c; then
    claude_terminal='kitten @ --to unix:/tmp/agent'
    hyprctl dispatch workspace special:
    eval $claude_terminal send-text "$content"
    eval $claude_terminal send-key Return
else
    wl-copy "$content"
    hyprctl dispatch sendshortcut CTRL, v,
fi
