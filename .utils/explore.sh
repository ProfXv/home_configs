cd "`~/.utils/path.sh`"
site="$(for f in `ls Sites.txt ~/.sites/*`; do cat $f; done | fzf)"
if [ -n "$site" ]; then nohup xdg-open $site > /dev/null &; fi
kill $KITTY_PID
