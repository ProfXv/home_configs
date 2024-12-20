#!/bin/zsh

hyprctl notify -1 1000 "rgb(ff1ea3)" "Just tell me what you wanna do!"
source ~/.chat/chat.zsh

# 定义文件名常量
CONVERSATION_FILE=/tmp/operations/operations.jsonl
RESPONSE_FILE=/tmp/operations/operations.md
RESPONSE_STATE=false

operations=`hyprctl binds -j | jq '.[] | select(.has_description) | .description' | nl`
echo $operations

mkdir -p /tmp/operations
append_to_conversation -r system -c "Using the given tool to select operation by query from the list below:\n$operations"
append_to_conversation -r user -c "`~/.asr/bin/iat_online_record_sample`"

response=`send_request -t select_operation_number`
content=`echo -E $response | jq -r '.choices[0].message.content'`
number=`echo -E $response | jq '.choices[0].message.tool_calls[0].function.arguments | fromjson | .number'`

operation=`echo $operations | sed -n "$number"p | grep -o '".*"'`
script=$(hyprctl binds -j | jq -r '.[] | select(.description == '$operation') | ("\(.dispatcher) \(.arg)")')

notify-send "$content" "$script"
eval hyprctl dispatch "\"$script\""
