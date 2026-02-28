#!/bin/sh

lang="${LANG%%_*}"

translations_zh='
{
  "mods": {},
  "keys": {
    "PgUp": "上页",
    "PgDn": "下页"
  },
  "desc": {
    "capture active window": "截取活动窗口",
    "capture full screen": "截取全屏",
    "capture selected area": "截取选定区域",
    "capture selected window": "截取选定窗口",
    "check system log": "查看系统日志",
    "copy focused content": "复制聚焦内容",
    "decrease microphone volume": "降低麦克风音量",
    "decrease screen brightness": "降低屏幕亮度",
    "decrease speaker volume": "降低扬声器音量",
    "edit anacrontab": "编辑定时任务",
    "enter clean mode": "进入清洁模式",
    "enter kill mode": "进入终止模式",
    "execute command": "执行命令",
    "execute focused content": "执行聚焦内容",
    "exit session": "退出会话",
    "focus backward in group": "聚焦组内上一个",
    "focus empty": "聚焦空白",
    "focus forward in group": "聚焦组内下一个",
    "generate focused content": "生成聚焦内容",
    "hibernate system": "休眠系统",
    "increase microphone volume": "提高麦克风音量",
    "increase screen brightness": "提高屏幕亮度",
    "increase speaker volume": "提高扬声器音量",
    "kill active window": "关闭活动窗口",
    "lock screen": "锁定屏幕",
    "move backward in group": "向组内后移",
    "move focus down": "向下移动焦点",
    "move focus left": "向左移动焦点",
    "move focus right": "向右移动焦点",
    "move focus up": "向上移动焦点",
    "move forward in group": "向组内前移",
    "move out of group": "移出组",
    "move to empty": "移至空白",
    "move to next workspace": "移至下一工作区",
    "move to previous workspace": "移至上一工作区",
    "move to scratchpad": "移至草稿板",
    "move window down": "下移窗口",
    "move window/group down": "下移窗口/组",
    "move window/group left": "左移窗口/组",
    "move window/group right": "右移窗口/组",
    "move window/group up": "上移窗口/组",
    "move window left": "左移窗口",
    "move window right": "右移窗口",
    "move window up": "上移窗口",
    "next media track": "下一曲",
    "next window": "下一窗口",
    "next workspace": "下一工作区",
    "notify layer switch": "通知层切换",
    "open bluetooth control": "打开蓝牙控制",
    "open browser": "打开浏览器",
    "open claude code": "打开Claude代码",
    "open config list with nvim": "用nvim打开配置列表",
    "open config list with yazi": "用yazi打开配置列表",
    "open config with claude": "用Claude打开配置",
    "open Desktop": "打开桌面",
    "open Documents": "打开文档",
    "open Downloads": "打开下载",
    "open editor": "打开编辑器",
    "open file manager": "打开文件管理器",
    "open focused content": "打开聚焦内容",
    "open home": "打开主目录",
    "open Jupyter": "打开Jupyter",
    "open keyboard programmer": "打开键盘编程器",
    "open Mathematica": "打开Mathematica",
    "open Music": "打开音乐",
    "open Pictures": "打开图片",
    "open Public": "打开公共",
    "open root": "打开根目录",
    "open system monitor": "打开系统监视器",
    "open Templates": "打开模板",
    "open terminal": "打开终端",
    "open Videos": "打开视频",
    "open wifi control": "打开WiFi控制",
    "paste focused content": "粘贴聚焦内容",
    "pin window": "固定窗口",
    "polish speeches": "润色语音",
    "poweroff system": "关闭系统",
    "previous media track": "上一曲",
    "previous window": "上一窗口",
    "previous workspace": "上一工作区",
    "reboot system": "重启系统",
    "rebuild NixOS config": "重建NixOS配置",
    "record active window": "录制活动窗口",
    "record full screen": "录制全屏",
    "record selected area": "录制选定区域",
    "record selected window": "录制选定窗口",
    "reload home config": "重载用户配置",
    "rename workspace": "重命名工作区",
    "reopen window group": "重新打开窗口组",
    "save webpage": "保存网页",
    "save window group": "保存窗口组",
    "select speeches": "选择语音",
    "select webpage": "选择网页",
    "send pause key": "发送暂停键",
    "speech 0": "语音0",
    "speech 1": "语音1",
    "speech 2": "语音2",
    "speech 3": "语音3",
    "speech 4": "语音4",
    "speech 5": "语音5",
    "speech 6": "语音6",
    "speech 7": "语音7",
    "speech 8": "语音8",
    "speech 9": "语音9",
    "suspend system": "挂起系统",
    "swap with next window": "与下一窗口交换",
    "swap with previous window": "与上一窗口交换",
    "swap workspaces": "交换工作区",
    "toggle annotator": "切换标注器",
    "toggle clipboard": "切换剪贴板",
    "toggle display power": "切换显示电源",
    "toggle floating": "切换浮动",
    "toggle fullscreen": "切换全屏",
    "toggle group": "切换组",
    "toggle keyboard": "切换键盘",
    "toggle launcher": "切换启动器",
    "toggle magnifier": "切换放大镜",
    "toggle media playback": "切换媒体播放",
    "toggle microphone mute": "切换麦克风静音",
    "toggle pinned windows": "切换固定窗口",
    "toggle pseudo": "切换伪平铺",
    "toggle scratchpad": "切换草稿板",
    "toggle speaker mute": "切换扬声器静音",
    "toggle split": "切换分割",
    "toggle status bar": "切换状态栏",
    "toggle unicode input": "切换Unicode输入",
    "toggle window info": "切换窗口信息",
    "type focused content": "输入聚焦内容",
    "view daily card": "查看每日卡片",
    "voice command 0": "语音命令0",
    "voice command 1": "语音命令1",
    "voice command 2": "语音命令2",
    "voice command 3": "语音命令3",
    "voice command 4": "语音命令4",
    "voice command 5": "语音命令5",
    "voice command 6": "语音命令6",
    "voice command 7": "语音命令7",
    "voice command 8": "语音命令8",
    "voice command 9": "语音命令9",
    "voice commands": "语音命令"
  }
}
'

if [ "$lang" = "zh" ]; then
  translations="$translations_zh"
else
  translations='{}'
fi

operation=$(
    hyprctl binds -j | jq -r --argjson tr "$translations" '
      def modmask_to_text:
        . as $m |
        (if (($m / 64) | floor % 2) == 1 then ($tr.mods.Super // "Super") else "" end) +
        (if (($m / 8) | floor % 2) == 1 then ($tr.mods.Alt // "Alt") else "" end) +
        (if (($m / 4) | floor % 2) == 1 then ($tr.mods.Ctrl // "Ctrl") else "" end) +
        (if ($m % 2) == 1 then ($tr.mods.Shift // "Shift") else "" end);

      def normalize_key:
        if . == "apostrophe" then "'"'"'"
        elif . == "up" then "↑"
        elif . == "down" then "↓"
        elif . == "left" then "←"
        elif . == "right" then "→"
        elif . == "return" then "󰌑"
        elif . == "tab" then "󰌒"
        elif . == "prior" then ($tr.keys.PgUp // "PgUp")
        elif . == "next" then ($tr.keys.PgDn // "PgDn")
        elif . == "grave" then "`"
        elif . == "F1" then "󱊫"
        elif . == "F2" then "󱊬"
        elif . == "F3" then "󱊭"
        elif . == "F4" then "󱊮"
        elif . == "F5" then "󱊯"
        elif . == "F6" then "󱊰"
        elif . == "F7" then "󱊱"
        elif . == "F8" then "󱊲"
        elif . == "F9" then "󱊳"
        elif . == "F10" then "󱊴"
        elif . == "F11" then "󱊵"
        elif . == "F12" then "󱊶"
        elif . == "mouse:272" then "󰍽L"
        elif . == "mouse:273" then "󰍽R"
        elif . == "mouse:274" then "󰍽M"
        elif . == "XF86AudioRaiseVolume" then "󰝝"
        elif . == "XF86AudioLowerVolume" then "󰝞"
        elif . == "XF86AudioMute" then "󰝟"
        elif . == "XF86AudioMicMute" then "󰍭"
        elif . == "XF86MonBrightnessUp" then "󰳲+"
        elif . == "XF86MonBrightnessDown" then "󰳲-"
        else .
        end;

      def translate_desc:
        . as $d | ($tr.desc[$d] // $d);

      .[] |
      select(.submap == "") |
      (
        (.modmask | modmask_to_text) as $mods |
        (.key | normalize_key) as $normalized_key |
        [
          ((if .locked then " " else "" end) +
           (if .mouse then "󰍽" else "" end) +
           (if .release then "󰕰" else "" end) +
           (if .repeat then "" else "" end) +
           (if .non_consuming then "⦽" else "" end) +
           (if .catch_all then "󰚾" else "" end)),
          $mods,
          $normalized_key,
          (if .has_description then (.description | translate_desc) else "" end),
          "󱊨 \(.dispatcher) \(.arg)"
        ] | @tsv
      )' | column -t -s $'\t' | fzf | sed 's/.*󱊨 //'
)

windows=`hyprctl activeworkspace -j | jq .windows`
if [ $windows != 1 ]; then hyprctl dispatch focuscurrentorlast; fi
eval hyprctl dispatch "\"$operation\""
