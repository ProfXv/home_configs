#!/bin/sh

cd ~/.claude/shell-snapshots
inotifywait -m -e create . | while read -r _ _ filename; do
    [[ "$filename" == snapshot-*.sh ]] && sleep 1 &&
    [[ "$(tail -n 1 "$filename")" == export* ]] && sed -i '$ d' "$filename"
done
