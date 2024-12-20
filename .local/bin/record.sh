#!/bin/bash

# two functions below are adapted from https://github.com/Gustash/Hyprshot
function slurp_window() {
    local name=`hyprctl -j monitors | jq -r 'map(.activeWorkspace.id) | join(",")'`
    local clients=`hyprctl -j clients | jq -r '[.[] | select(.workspace.id | contains('$name'))]'`
    local boxes="$(echo $clients | jq -r '.[] | "\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')"
    slurp -r <<< "$boxes"
}

function slurp_active_window() {
    local active_window=`hyprctl -j activewindow`
    local box=$(echo $active_window | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
    echo "$box"
}

source path.sh
action=$1
area=$2
case $action in
    "capture")
        mkdir -p Pictures
        path=Pictures/`date +"%s.png"`
        case $area in
            "full")
                grim - | tee $path | wl-copy
                ;;
            "window-active")
                grim -g "`slurp_active_window`" - | tee $path | wl-copy
                ;;
            "window-select")
                grim -g "`slurp_window`" - | tee $path | wl-copy
                ;;
            "select")
                grim -g "`slurp`" - | tee $path | wl-copy
                ;;
        esac
        ;;
    "record")
        mkdir -p Videos
        path=Videos/`date +"%s.mp4"`
        case $area in
            "full")
                pkill wf-recorder || wf-recorder -f $path
                ;;
            "window-active")
                pkill wf-recorder || wf-recorder -f $path -g "`slurp_active_window`"
                ;;
            "window-select")
                pkill wf-recorder || wf-recorder -f $path -g "`slurp_window`"
                ;;
            "select")
                pkill wf-recorder || wf-recorder -f $path -g "`slurp`"
                ;;
        esac
        ;;
esac
