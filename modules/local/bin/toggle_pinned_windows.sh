#!/bin/sh

active=$(hyprctl activewindow -j 2>/dev/null)
[[ -n "$active" ]] && {
    addr=$(echo "$active" | jq -r '.address')
    pinned=$(echo "$active" | jq -r '.pinned')
    [[ "$pinned" == "true" ]] && {
        hyprctl dispatch pin "address:$addr" &&
        hyprctl dispatch movetoworkspacesilent "special:hidden,address:$addr"
        exit 0
    }
}

clients=$(hyprctl clients -j | jq -r '.[]')
pinned=$(echo "$clients" | jq -r 'select(.pinned == true) | .address')
[[ -n "$pinned" ]] && {
    while read addr; do
        hyprctl dispatch pin "address:$addr" &&
        hyprctl dispatch movetoworkspacesilent "special:hidden,address:$addr"
    done <<< "$pinned"
} || {
    hidden=$(echo "$clients" | jq -r 'select(.workspace.name == "special:hidden") | .address')
    [[ -n "$hidden" ]] && {
        current_ws=$(hyprctl activeworkspace -j | jq '.id')
        while read addr; do
            hyprctl dispatch movetoworkspacesilent "$current_ws,address:$addr" &&
            hyprctl dispatch pin "address:$addr"
        done <<< "$hidden"
    }
}
