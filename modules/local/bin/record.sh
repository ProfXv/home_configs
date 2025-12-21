#!/usr/bin/env bash

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

action=$1
area=$2
case $action in
    "capture")
        path=~/Pictures/`date +"%s.png"`
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
        ln -sf $path /tmp/snapshot_picture
        ;;
    "record")
        path=~/Videos/`date +"%s.mp4"`
        pkill wf-recorder && hyprctl notify -1 1000 "rgb(ff1ea3)" "End Recording." || {
            hyprctl notify -1 1000 "rgb(ff1ea3)" "Start Recording."
            case $area in
                "full")
                    wf-recorder -f $path
                    ;;
                "window-active")
                    wf-recorder -f $path -g "`slurp_active_window`"
                    ;;
                "window-select")
                    wf-recorder -f $path -g "`slurp_window`"
                    ;;
                "select")
                    wf-recorder -f $path -g "`slurp`"
                    ;;
            esac
            ln -sf $path /tmp/snapshot_video
        }
        ;;
esac
