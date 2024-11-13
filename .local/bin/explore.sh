#!/bin/bash

site="$(for f in `ls Sites.txt ~/.sites/*`; do cat $f; done | fzf -m)"
if [ -n "$site" ]; then nohup xdg-open $site > /dev/null; fi &
kill $KITTY_PID
