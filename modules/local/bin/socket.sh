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
        Alacritty)
            pid=`hyprctl activewindow -j | jq .pid`
            name=`pstree $pid | grep -o '[^-]*$'`
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

tracking=$XDG_RUNTIME_DIR/hypr_visualize

visualize_init() {
    local IFS=" "
    addr=0x$1
    infos=$(hyprctl clients -j | jq '.[] | select(.address == "'$addr'")')
    $(echo "$infos" | jq '.floating or .pseudo') || {
        pid=$(echo "$infos" | jq '.pid')
        init_ticks=$(awk -v r="$pid" '
            function walk(p,  f,line,n,c,i){
                f="/proc/"p"/task/"p"/children"
                if((getline line<f)<=0){close(f);return}
                close(f);n=split(line,c," ")
                for(i=1;i<=n;i++){if(c[i]=="")continue;all[++nall]=c[i];walk(c[i])}}
            BEGIN{all[1]=r;nall=1;walk(r)
                for(i=1;i<=nall;i++){
                    f="/proc/"all[i]"/stat"
                    if((getline l<f)>0){sub(/^[0-9]+ \([^)]*\) /,"",l);split(l,g," ");t+=g[12]+g[13]}
                    close(f)}
                print t+0}')
        echo "$pid 0 0 $(date +%s.%N) $init_ticks" > "$tracking/$addr"
    }
}

visualize_loop() {
    local IFS=" "
    rm -rf "$tracking"
    mkdir -p "$tracking"
    local clk=$(getconf CLK_TCK)
    local mem_kb=$(awk '/MemTotal/{print $2}' /proc/meminfo)
    while true; do
        set -- "$tracking"/0x*
        current_time=$(date +%s.%N)
        batch=""
        for f; do
            [ -f "$f" ] || continue
            addr=${f##*/}
            read pid total_cpu total_mem last_time prev_ticks < "$f"
            [ -d "/proc/$pid" ] || { rm "$f"; continue; }
            color=$(awk \
                -v r="$pid" -v pt="$prev_ticks" \
                -v lt="$last_time" -v ct="$current_time" \
                -v clk="$clk" -v mk="$mem_kb" \
                -v tc="$total_cpu" -v tm="$total_mem" \
                -v f="$f" '
                function abs(v){return v<0?-v:v}
                function cv(x){fr=x-int(x);return 1-(abs(fr-0.5)/0.5)}
                function walk(p,  cf,line,n,c,i){
                    cf="/proc/"p"/task/"p"/children"
                    if((getline line<cf)<=0){close(cf);return}
                    close(cf);n=split(line,c," ")
                    for(i=1;i<=n;i++){if(c[i]=="")continue;all[++nall]=c[i];walk(c[i])}}
                BEGIN{
                    all[1]=r;nall=1;walk(r)
                    for(i=1;i<=nall;i++){
                        p="/proc/"all[i]"/stat"
                        if((getline l<p)>0){sub(/^[0-9]+ \([^)]*\) /,"",l);split(l,g," ")
                            t+=g[12]+g[13];rss+=g[22]}
                        close(p)}
                    td=ct-lt
                    cpu=(pt>0&&td>0)?(t-pt)/(td*clk)*100:0
                    mem=(mk>0)?rss*4/mk*100:0
                    tc+=cpu*td/100;tm+=mem*td/100
                    printf "rgb(%02x%02x00)",int(cv(tm)*255+.5),int(cv(tc)*255+.5)
                    print r,tc,tm,ct,t>f;close(f)}')
            batch="$batch;dispatch setprop address:$addr active_border_color $color;dispatch setprop address:$addr inactive_border_color $color"
        done
        [ -n "$batch" ] && hyprctl --batch "${batch#;}" > /dev/null
    done
}

IFS=">"
handle() {
    sqlite3 ~/.log.db "PRAGMA busy_timeout=1000; INSERT INTO socket VALUES (NULL, datetime('now', 'localtime'), '$key', '$value')" > /dev/null
    case "$key" in
        openwindow)
            if $submap; then hyprctl dispatch submap reset; submap=false; fi
            addr=`echo $value | cut -d, -f 1`
            value=`echo $value | cut -d, -f 3-`
            refresh
            visualize_init $addr
            notify=0
            ;;
        closewindow|fullscreen)
            if $submap; then hyprctl dispatch submap reset; submap=false; fi
            notify=0
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

visualize_loop &

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock |
    while read -r key _ value; do handle; done
