#!/bin/sh

sites="$(for f in `ls Sites.txt ~/.sites/*`; do cat $f; done | fzf -m)"
if [ -n "$sites" ]; then for site in $sites; do nohup xdg-open $site > /dev/null & done fi
kill $KITTY_PID
