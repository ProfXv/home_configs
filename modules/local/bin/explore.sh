#!/bin/sh

sites="$(for f in `ls ~/.sites/*`; do cat $f; done | fzf -m | cut -f 2)"
if [ -n "$sites" ]; then for site in $sites; do setsid xdg-open $site & done; fi
sleep .1
