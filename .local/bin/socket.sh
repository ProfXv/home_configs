#!/bin/sh

rebind() {
    hyprctl keyword unbind ", pause"
    class=`echo $value | cut -d, -f 1`
    name=`echo $value | cut -d, -f 2-`
    case $class in
        kitty)
            pid=`hyprctl activewindow -j | jq .pid`
            name=`pstree -T $pid | grep -o '[^-]*$'`
            case $name in
                vi*|vim*|nvim*)
                    hyprctl keyword bind ", pause, sendshortcut, , escape,"
                    ;;
                yazi*|btop*|man*|git\ diff*)
                    hyprctl keyword bind ", pause, sendshortcut, , q,"
                    ;;
                *)
                    hyprctl keyword bind ", pause, sendshortcut, CTRL, d,"
                    ;;
            esac
            ;;
        firefox)
            hyprctl keyword bind ", pause, sendshortcut, CTRL, w,"
            ;;
        *)
            hyprctl keyword bind ", pause, sendshortcut, , escape,"
            ;;
    esac
}

IFS=">"
handle() {
    echo -e `date +'%F %T'`\\t"$key"\\t"$value" >> ~/.socket_log
    case "$key" in
        openwindow)
            if $submap; then hyprctl dispatch submap reset; submap=false; fi
            value=`echo $value | cut -d, -f 3-`
            rebind
            notify=1
            ;;
        closewindow|fullscreen)
            if $submap; then hyprctl dispatch submap reset; submap=false; fi
            notify=1
            ;;
        workspacev2|renameworkspace)
            workspace_id=`echo $value | cut -d, -f 1`
            workspace_name=`echo $value | cut -d, -f 2-`
            [ -z `echo $workspace_id | grep -` ] && [ "$workspace_id" != "$workspace_name" ] &&
            path=~/Desktop/Projects/ours/$workspace_name && mkdir -p "$path" || path=~
            echo $path > /tmp/path
            ;;
        activewindow)
            rebind
            notify=0
            ;;
        submap)
            if [ -n "$value" ] && [ "$value" != 'clean' ]; then submap=true; fi
            ;;
        *)
            notify=0
            ;;
    esac
    if [ $notify -eq 1 ]; then hyprctl notify -1 1000 "rgb(ff1ea3)" "$key: $value"; fi
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock |
    while read -r key _ value; do handle; done
