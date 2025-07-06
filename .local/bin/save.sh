#!/bin/bash

# 1. 复制当前浏览器链接 (恢复最初版本)
hyprctl dispatch focuscurrentorlast
sleep 0.5 && ydotool key -d 100 29:1 38:1 38:0 46:1 46:0 29:0 && sleep 0.5
hyprctl dispatch focuscurrentorlast

# 2. 获取链接
url=$(wl-paste -p)

# 3. 验证是否为有效URL
if [[ ! "$url" =~ ^https?:// ]]; then
    hyprctl notify -1 3000 "rgb(ff1ea3)" "剪贴板内容不是有效URL"
    exit 1
fi

# 4. 提供操作选择
choice=$(echo -e "保存链接\n克隆GitHub项目" | fzf --prompt="选择操作:")

case "$choice" in
    "保存链接")
        # 获取链接名称
        hyprctl notify -1 1000 "rgb(ff1ea3)" "请说出链接名称"
        name=$(~/.asr/bin/iat_online_record_sample | sed 's/.$//')
        hyprctl notify -1 1000 "rgb(ff1ea3)" "名称已记录"
        # 保存到文件 (确保包含https://)
        echo -e "${name}\t${url}" >> ~/.sites/Sites.txt
        hyprctl notify -1 2000 "rgb(00ff00)" "链接已保存"
        ;;
    "克隆GitHub项目")
        # 提取项目路径
        if [[ "$url" =~ github.com/([^/]+/[^/]+) ]]; then
            repo_path="${BASH_REMATCH[1]}"
            repo_name=$(basename "$repo_path")
            # 克隆到指定目录
            clone_dir="$HOME/Desktop/Projects/$repo_name"
            git clone "$url" "$clone_dir"
        else
            hyprctl notify -1 3000 "rgb(ff0000)" "不是有效的GitHub URL"
        fi
        ;;
    *)
        hyprctl notify -1 2000 "rgb(ff1ea3)" "操作已取消"
        exit 0
        ;;
esac
