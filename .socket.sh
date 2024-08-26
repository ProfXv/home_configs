#!/bin/sh

IFS=">"
handle() {
  echo -e `date +'%F %T'`\\t"$key"\\t"$value" >> .socket_log
  case "$key" in
    workspace|openwindow|closewindow|activespecial|fullscreen)
      if [ "$submap" -eq 1 ]; then
        submap=0
        hyprctl dispatch submap reset
      fi
      notify=1
      ;;
    submap)
      if [ -n "$value" ]; then submap=1; fi
      notify=1
      ;;
    *)
      notify=0
      ;;
  esac
  if [ $notify -eq 1 ]; then hyprctl notify -1 1000 "rgb(ff1ea3)" "$key: $value"; fi
}

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r key _ value; do handle; done
