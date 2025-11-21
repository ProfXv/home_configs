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
        nyxt)
            hyprctl keyword bind ", pause, sendshortcut, CTRL, w,"
            ;;
        crystal-board)
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
        pids=$(ps --ppid $pid --pid $pid -o pid --no-headers | tr '\n' ',')
        last_time=$(date +%s.%N)
        total_cpu=0
        total_mem=0
        while ps -p $pid > /dev/null; do
            current_time=$(date +%s.%N)
            time_delta=$(awk -v start="$last_time" -v end="$current_time" 'BEGIN { print end - start }')
            last_time=$current_time
            cpu=$(top -b -n 1 -p "$pids" | awk '/^ *[0-9]+ / {cpu += $9 + 0} END {print cpu}')
            mem=$(top -b -n 1 -p "$pids" | awk '/^ *[0-9]+ / {mem += $10 + 0} END {print mem}')
            read cpu_color_level mem_color_level total_cpu total_mem <<< $(awk \
                -v cpu="$cpu" \
                -v mem="$mem" \
                -v time_delta="$time_delta" \
                -v total_cpu="$total_cpu" \
                -v total_mem="$total_mem" '
                function abs(v) { return v < 0 ? -v : v }
                function calc_value(x) { frac = x - int(x); return 1 - (abs(frac - 0.5) / 0.5); }
                BEGIN {
                    total_cpu += (cpu * time_delta) / 100;
                    total_mem += (mem * time_delta) / 100;
                    cpu_frac = calc_value(total_cpu);
                    mem_frac = calc_value(total_mem);
                    print int(cpu_frac * 255 + 0.5), int(mem_frac * 255 + 0.5), total_cpu, total_mem;
                }
            ')
            color="rgb($(printf "%02x%02x00" "$mem_color_level" "$cpu_color_level"))"
            for var in '' in; do
                hyprctl setprop -q address:$addr "$var"activebordercolor $color
            done
        done
    }
}

IFS=">"
handle() {
    sqlite3 ~/.log.db "INSERT INTO socket VALUES (NULL, datetime('now', 'localtime'), '$key', '$value')"
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
