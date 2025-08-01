#!/bin/sh

refresh() {
    hyprctl keyword input:follow_mouse 1
    hyprctl keyword decoration:rounding 10
    hyprctl keyword decoration:inactive_opacity .5
    hyprctl keyword decoration:blur:enabled true
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
                yazi*|btop*|man*|more*|less*|git\ diff*)
                    hyprctl keyword bind ", pause, sendshortcut, , q,"
                    ;;
                *)
                    hyprctl keyword bind ", pause, sendshortcut, CTRL, d,"
                    ;;
            esac
            ;;
        )
            hyprctl keyword input:follow_mouse 0
            ;;
        firefox-developer-edition)
            hyprctl keyword bind ", pause, sendshortcut, CTRL, w,"
            ;;
        CrystalBoard)
            hyprctl keyword decoration:rounding 0
            hyprctl keyword decoration:inactive_opacity 1
            hyprctl keyword decoration:blur:enabled false
            hyprctl keyword bind ", pause, sendshortcut, , escape,"
            ;;
        *)
            hyprctl keyword bind ", pause, sendshortcut, , escape,"
            ;;
    esac
}

visualize() {
    local IFS=" "
    addr=0x$1
    infos=`hyprctl clients -j | jq '.[] | select(.address == "'$addr'")'`
    `echo $infos | jq '.floating or .pseudo'` || {
        pid=`echo $infos | jq '.pid'`
        pids=`ps --ppid $pid --pid $pid -o pid --no-headers`
        while true; do
            read cpu mem <<< $(echo "$pids" | xargs -I{} top -b -n 1 -p {} | awk '
            /^ *[0-9]+ / {
                cpu += $9 + 0;
                mem += $10 + 0;
            }
            END {
                if (cpu != "" && mem != "") {
                    if (cpu > 100) {cpu = 100}
                    print int(cpu/100*255+.5), int(mem/100*255+.5);
                }
            }')
            [ -z "$cpu$mem" ] && break
            color="rgb(`printf "%02x" $cpu``printf "%02x" $mem`00)"
            for var in '' in; do
                hyprctl setprop -q address:$addr "$var"activebordercolor $color
            done
        done
    }
}

IFS=">"
handle() {
    echo -e `date +'%F %T'`\\t"$key"\\t"$value" >> ~/.socket_log
    case "$key" in
        openwindow)
            if $submap; then hyprctl dispatch submap reset; submap=false; fi
            addr=`echo $value | cut -d, -f 1`
            value=`echo $value | cut -d, -f 3-`
            refresh
            visualize $addr &
            notify=1
            ;;
        closewindow|fullscreen)
            if $submap; then hyprctl dispatch submap reset; submap=false; fi
            notify=1
            ;;
        workspacev2|renameworkspace)
            source path.sh
            rm ~/?
            ln -s $PROJECT_HOME ~/?
            ;;
        activewindow)
            refresh
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
