#!/bin/sh

window_json=$(hyprctl activewindow -j 2>/dev/null)
[ -z "$window_json" ] && exit 1

class=$(echo "$window_json" | jq -r '.class')
pid=$(echo "$window_json" | jq -r '.pid')

modifier=""
key="escape"

case "$class" in
    kitty)
        hyprctl notify 1 3000 "rgb(ff1ea3)" "kitty"
        [ -n "$pid" ] && [ "$pid" -gt 0 ] && {
            proc_name=$(pstree -T "$pid" 2>/dev/null | grep -o '[^-]*$')
            case "$proc_name" in
                vi*|vim*|nvim*)
                    modifier=""
                    key="escape"
                    hyprctl notify 1 3000 "rgb(ff1ea3)" "vim/nvim"
                    ;;
                yazi*|btop*|man*|more*|less*|git\ diff*)
                    modifier=""
                    key="q"
                    hyprctl notify 1 3000 "rgb(ff1ea3)" "yazi/btop/man"
                    ;;
                *)
                    modifier="CTRL"
                    key="d"
                    hyprctl notify 1 3000 "rgb(ff1ea3)" "kitty default"
                    ;;
            esac
        }
        ;;
    nyxt)
        modifier="CTRL"
        key="w"
        hyprctl notify 1 3000 "rgb(ff1ea3)" "nyxt"
        ;;
    )
        hyprctl keyword input:follow_mouse 0
        hyprctl notify 1 3000 "rgb(ff1ea3)" ""
        exit 0
        ;;
    crystal-board)
        hyprctl keyword decoration:rounding 0
        hyprctl keyword decoration:inactive_opacity 1
        hyprctl keyword decoration:blur:enabled false
        modifier=""
        key="escape"
        hyprctl notify 1 3000 "rgb(ff1ea3)" "crystal-board"
        ;;
    *)
        modifier=""
        key="escape"
        hyprctl notify 1 3000 "rgb(ff1ea3)" "default ($class)"
        ;;
esac

hyprctl dispatch sendshortcut "$modifier, $key,"