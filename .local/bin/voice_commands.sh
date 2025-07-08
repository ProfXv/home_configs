#!/bin/zsh

log_path=~/.daily/speak_count
echo $(( $(cat $log_path) + 1 )) > $log_path
hyprctl notify -1 1000 "rgb(ff1ea3)" "Just tell me what you wanna do!"
source ~/.chat/chat.zsh
MODEL_NAME=deepseek-chat

# 定义文件名常量
CONVERSATION_FILE=/tmp/operations/operations.jsonl

operations=`hyprctl binds -j | jq '.[] | select(.has_description) | .description' | nl`
content="Operation succeeded."

mkdir -p /tmp/operations
append_to_conversation -r system -c "候选操作:\n$operations"
append_to_conversation -r user -c "`~/.asr/bin/iat_online_record_sample`"

response=`send_request -t select_operation_number -t set_reminder`
echo -E $response | jq
content=`echo -E $response | jq -r '.choices[0].message.content'`
tool_calls=`echo -E $response | jq '.choices[0].message.tool_calls'`
if [ -n "$content" ]; then notify-send Reply "$content"; fi


if [ -n "$tool_calls" ]; then
    echo -E $tool_calls | jq -c '.[]' | while read -r tool_call; do
        name=`echo -E $tool_call | jq -r '.function.name'`
        arguments=`echo -E $tool_call | jq -r '.function.arguments'`

        case "$name" in
            select_operation_number)
                number=`echo -E $arguments | jq -r '.number'`
                operation=`echo $operations | sed -n "$number"p | grep -o '\".*\"'`
                script=`hyprctl binds -j | jq -r '.[] | select(.description == '$operation') | ("\(.dispatcher) \(.arg)")'`
                notify-send Operation "$script"
                eval hyprctl dispatch "\"$script\""
                ;;
            set_reminder)
                time=`echo -E $arguments | jq -r '.time'`
                message=`echo -E $arguments | jq -r '.message'`
                set_reminder.sh "$time" "$message"
                notify-send "Reminder Set" "Your reminder is set for '$time'."
                ;;
        esac
    done
fi

rm $CONVERSATION_FILE
