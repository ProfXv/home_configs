#!/bin/sh

TOTAL_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$AUDIO_FILE")
FADE_OUT_START_TIME=$(awk "BEGIN {print $TOTAL_DURATION - 5}")

echo "notify-send '提醒' \"$2\" && ffmpeg -i \"$AUDIO_FILE\" -af \"afade=t=in:d=5,afade=t=out:st=${FADE_OUT_START_TIME}:d=5\" -f wav - | ffplay -nodisp -autoexit - &>/dev/null &" | at "$1"
