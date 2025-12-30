#!/bin/sh

log_file="$HOME/.log/smart_pause.log"
mkdir -p "$(dirname "$log_file")"

log() {
    printf '%s - %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$log_file"
}

window_json=$(hyprctl activewindow -j 2>/dev/null)
[ -z "$window_json" ] && exit 1

class=$(echo "$window_json" | jq -r '.class')
pid=$(echo "$window_json" | jq -r '.pid')

modifier=""
key="escape"

case "$class" in
    kitty)
        [ -n "$pid" ] && [ "$pid" -gt 0 ] && {
            proc_tree=$(pstree -T "$pid" 2>/dev/null || pstree "$pid" 2>/dev/null)
            [ -z "$proc_tree" ] && proc_tree="(no tree)"
            proc_name=$(echo "$proc_tree" | grep -o '[^-]*$')
            [ -z "$proc_name" ] && proc_name="(unknown)"
            proc_tree_short=$(echo "$proc_tree" | tr '\n' ' ' | head -c 200)

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
            log "window: $class, pid: $pid, tree: $proc_tree_short, action: sendshortcut $modifier, $key"
        }
        ;;
    nyxt)
        modifier="CTRL"
        key="w"
        hyprctl notify 1 3000 "rgb(ff1ea3)" "nyxt"
        log "window: $class, pid: $pid, action: sendshortcut $modifier, $key"
        ;;
    )
        hyprctl keyword input:follow_mouse 0
        hyprctl notify 1 3000 "rgb(ff1ea3)" ""
        log "window: $class, pid: $pid, action: set input:follow_mouse 0"
        exit 0
        ;;
    crystal-board)
        hyprctl keyword decoration:rounding 0
        hyprctl keyword decoration:inactive_opacity 1
        hyprctl keyword decoration:blur:enabled false
        modifier=""
        key="escape"
        hyprctl notify 1 3000 "rgb(ff1ea3)" "crystal-board"
        log "window: $class, pid: $pid, action: sendshortcut $modifier, $key + decoration changes"
        ;;
    *)
        modifier=""
        key="escape"
        hyprctl notify 1 3000 "rgb(ff1ea3)" "default ($class)"
        log "window: $class, pid: $pid, action: sendshortcut $modifier, $key"
        ;;
esac

hyprctl dispatch sendshortcut "$modifier, $key,"