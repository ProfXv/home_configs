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
            hyprctl keyword unbind "SUPER CTRL ALT, mouse_down"
            hyprctl keyword unbind "SUPER CTRL ALT, mouse_up"
            hyprctl keyword unbind "SUPER SHIFT CTRL ALT, mouse_down"
            hyprctl keyword unbind "SUPER SHIFT CTRL ALT, mouse_up"
            case `echo $value | cut -d, -f 1` in
                kitty)
                    hyprctl keyword bind "SUPER CTRL ALT, mouse_down, sendshortcut, CTRL SHIFT, bracketleft,"
                    hyprctl keyword bind "SUPER CTRL ALT, mouse_up, sendshortcut, CTRL SHIFT, bracketright,"
                    # hyprland get troubles when executing the binds below, we need to fix it by ourselves
                    hyprctl keyword bind "SUPER SHIFT CTRL ALT, mouse_down, sendshortcut, CTRL SHIFT, b,"
                    hyprctl keyword bind "SUPER SHIFT CTRL ALT, mouse_up, sendshortcut, CTRL SHIFT, f,"
                    ;;
                firefox)
                    # also, don't work at all, but anyway we first put it here
                    hyprctl keyword bind "SUPER CTRL ALT, mouse_down, sendshortcut, CTRL, prior,"
                    hyprctl keyword bind "SUPER CTRL ALT, mouse_up, sendshortcut, CTRL, next,"
                    hyprctl keyword bind "SUPER SHIFT CTRL ALT, mouse_down, sendshortcut, CTRL SHIFT, prior,"
                    hyprctl keyword bind "SUPER SHIFT CTRL ALT, mouse_up, sendshortcut, CTRL SHIFT, next,"
                    ;;
                *)
                    ;;
            esac
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
