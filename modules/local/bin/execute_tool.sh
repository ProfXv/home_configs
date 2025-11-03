#!/bin/sh

TOOL_NAME=$1
JSON_PARAMS=$(cat)

case "$TOOL_NAME" in
    get_operation_list)
        hyprctl binds -j | jq '.[] | select(.has_description) | .description' | nl -v 0 | sed 's/^ *//g'
        ;;
    select_operation_number)
        number=$(echo -E "$JSON_PARAMS" | jq -r '.number')
        operation=`hyprctl binds -j | jq "([.[] | select(.has_description) | .description])[$number]"`
        script=`hyprctl binds -j | jq -r '.[] | select(.description == '"$operation"') | ("\(.dispatcher) \(.arg)")'`
        notify-send Operation "$script"
        eval hyprctl dispatch "\"$script\""
        ;;
    set_reminder)
        time=$(echo -E "$JSON_PARAMS" | jq -r '.time')
        message=$(echo -E "$JSON_PARAMS" | jq -r '.message')
        TOTAL_DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$AUDIO_FILE")
        echo "notify-send '提醒' \"$message\" && ffmpeg -i \"$AUDIO_FILE\" -af \"afade=t=in:d=5\" -f wav - | ffplay -nodisp -autoexit - &>/dev/null &" | at "$time"
        notify-send 'Schedule' "One-time Clock set successfully for '$time'."
        ;;
esac
