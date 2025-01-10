#!/bin/bash

# 文件路径
state_file=".phone_state"

secure_move() {
    adb pull -a "$1" "$2"
    remote_hash=$(adb shell sha256sum "$1" | cut -d ' ' -f 1)
    local_hash=$(sha256sum "$2/$(basename "$1")" | cut -d ' ' -f 1)
    [[ "$remote_hash" == "$local_hash" ]] && adb shell rm "$1"
}

sync_directory() {
    local src_dir="$1"
    local dest_dir="$2"
    mkdir -p "$dest_dir"
    shift 2
    for ext in "$@"; do
        files=$(adb shell find "$src_dir" -iname "*.$ext")
        for file in $files; do
            secure_move "$file" "$dest_dir"
        done
    done
}

# 定义连接和断开时的操作
on_connect() {
    echo "手机已连接"
    hyprctl dispatch exec '[workspace name:🖧 silent] scrcpy'
    sync_directory /sdcard/Sounds/ ~/Music/Sounds wav
    sync_directory /sdcard/Pictures/Screenshots ~/Pictures/Screenshots jpg png
    sync_directory /sdcard/DCIM/Camera ~/Pictures/Camera gif heic jpeg jpg pic png webp
    sync_directory /sdcard/DCIM/Camera ~/Videos/Camera mov mp4
    # 在这里添加连接时的操作，例如启动同步脚本
}

off_connect() {
    echo "手机已断开"
    # 在这里添加断开时的操作，例如停止同步脚本
}

# 初始状态
prev_state="$(cat "$state_file")"
if [ "$prev_state" == "1" ]; then on_connect; fi

# 开始监控文件
inotifywait -m -e modify "$state_file" | while read -r line; do
    # 读取当前状态
    current_state="$(cat "$state_file")"

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
