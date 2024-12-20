#!/bin/sh

sites="$(for f in `ls Sites.txt ~/.sites/*`; do cat $f; done | fzf -m)"
if [ -n "$sites" ]; then for site in $sites; do nohup firefox --new-window $site > /dev/null & done fi
sleep .1
kill $KITTY_PID
