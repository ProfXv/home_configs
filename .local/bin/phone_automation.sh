#!/bin/bash

# 文件路径
file=".phone_state"

# 定义连接和断开时的操作
on_connect() {
    echo "手机已连接"
    hyprctl dispatch exec '[workspace name:🖧 silent] scrcpy'
    # 在这里添加连接时的操作，例如启动同步脚本
}

off_connect() {
    echo "手机已断开"
    # 在这里添加断开时的操作，例如停止同步脚本
}

# 初始状态
prev_state="$(cat "$file")"
if [ "$prev_state" == "1" ]; then on_connect; fi

# 开始监控文件
inotifywait -m -e modify "$file" | while read -r line; do
    # 读取当前状态
    current_state="$(cat "$file")"

    # 检查状态是否发生变化
    if [ "$current_state" != "$prev_state" ]; then
        if [ "$current_state" == "1" ]; then
            on_connect
        elif [ "$current_state" == "0" ]; then
            off_connect
        fi
        # 更新状态
        prev_state="$current_state"
    fi

done
