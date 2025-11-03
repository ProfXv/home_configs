#!/bin/sh

sites="$(for f in `ls Sites.txt ~/.sites/*`; do cat $f; done | fzf -m --cycle | cut -f 2)"
if [ -n "$sites" ]; then for site in $sites; do nohup nyxt -S $site > /dev/null & done fi
sleep .1
kill $KITTY_PID
