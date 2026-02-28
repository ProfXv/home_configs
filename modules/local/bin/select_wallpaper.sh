#!/bin/sh

wallpaper_dir=~/Downloads/wallpapers
while true; do
  list=$(ls $wallpaper_dir)
  pos=$(echo "$list" | grep -Fnx "$selected" | cut -d: -f1)
  selected=$(echo "$list" | fzf --cycle --bind "load:pos($pos)")
  [ -z "$selected" ] && break
  ln -sf "$wallpaper_dir/$selected" ~/.wallpaper && pkill -USR2 swaybg
done
