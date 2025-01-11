#!/bin/zsh

log_path=~/.daily/speak_count
echo $(( $(cat $log_path) + 1 )) > $log_path
hyprctl notify -1 1000 "rgb(ff1ea3)" "Just tell me what you wanna do!"
source ~/.chat/chat.zsh

# 定义文件名常量
CONVERSATION_FILE=/tmp/operations/operations.jsonl

operations=`hyprctl binds -j | jq '.[] | select(.has_description) | .description' | nl`
content="Operation succeeded."

mkdir -p /tmp/operations
append_to_conversation -r system -c "候选操作:\n$operations"
append_to_conversation -r user -c "`~/.asr/bin/iat_online_record_sample`"

response=`send_request -t select_operation_number`
echo -E $response | jq
content=`echo -E $response | jq -r '.choices[0].message.content'`
numbers=`echo -E $response | jq '.choices[0].message.tool_calls[].function.arguments | fromjson | .number'`
if [ -n "$content" ]; then notify-send Reply "$content"; fi

for number in `echo $numbers`; do
    operation=`echo $operations | sed -n "$number"p | grep -o '".*"'`
    script=$(hyprctl binds -j | jq -r '.[] | select(.description == '$operation') | ("\(.dispatcher) \(.arg)")')
    notify-send Operation "$script"
    eval hyprctl dispatch "\"$script\""
done

rm $CONVERSATION_FILE
