#!/bin/sh

IFS=">"
handle() {
    echo -e `date +'%F %T'`\\t"$key"\\t"$value" >> ~/.socket_log
    case "$key" in
        workspace|openwindow|closewindow|activespecial|fullscreen)
            if $submap; then hyprctl dispatch submap reset; submap=false; fi
            notify=1
            ;;
        activewindow)
            hyprctl keyword unbind ", pause"
            class=`echo $value | cut -d, -f 1`
            name=`echo $value | cut -d, -f 2-`
            case $class in
                kitty)
                    case $name in
                        vi*|vim*|nvim*)
                            hyprctl keyword bind ", pause, sendshortcut, , escape,"
                            ;;
                        Yazi*|btop*|man*|git\ diff*)
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

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r key _ value; do handle; done
