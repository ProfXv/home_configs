#!/usr/bin/env bash

active_window=$(hyprctl activewindow -j | jq -r '.address')

if [[ -z "$active_window" || "$active_window" == "null" ]]; then
    hyprctl notify -1 3000 "rgb(ff0000)" "无法获取活动窗口"
    exit 1
fi

hyprctl dispatch pass CTRL, l, address:$active_window
hyprctl dispatch pass CTRL, c, address:$active_window

url=$(wl-paste -p)

if [[ ! "$url" =~ ^https?:// ]]; then
    hyprctl notify -1 3000 "rgb(ff1ea3)" "剪贴板内容不是有效URL"
    exit 1
fi

alacritty --class save.sh bash -c "
choice=\$(echo -e '保存链接\\n克隆GitHub项目' | fzf --prompt='选择操作:')

case \"\$choice\" in
    '保存链接')
        hyprctl notify -1 1000 'rgb(ff1ea3)' '请说出链接名称'
        name=\$(ASRCaption | sed 's/.\$//')
        hyprctl notify -1 1000 'rgb(ff1ea3)' '名称已记录'
        echo -e \"\${name}\\t$url\" >> ~/.sites/Sites.txt
        hyprctl notify -1 2000 'rgb(00ff00)' '链接已保存'
        ;;
    '克隆GitHub项目')
        if [[ '$url' =~ github.com/([^/]+/[^/]+) ]]; then
            repo_path=\"\${BASH_REMATCH[1]}\"
            repo_name=\$(basename \"\$repo_path\")
            clone_dir=\"\$HOME/Desktop/Projects/\$repo_name\"
            git clone '$url' \"\$clone_dir\"
        else
            hyprctl notify -1 3000 'rgb(ff0000)' '不是有效的GitHub URL'
        fi
        ;;
    *)
        hyprctl notify -1 2000 'rgb(ff1ea3)' '操作已取消'
        exit 0
        ;;
esac
"
