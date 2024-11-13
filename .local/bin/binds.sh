#!/bin/bash

if pkill wvkbd-mobintl; then m=m; f=1; else (wvkbd-mobintl -L 520 &); un=un; f=0; fi
hyprctl keyword input:follow_mouse $f

# Change shortcuts
hyprctl keyword "$un"bind "SUPER SHIFT, mouse:272, fullscreen"
hyprctl keyword "$un"bind "SUPER CTRL, mouse:272, togglefloating"
hyprctl keyword "$un"bind "SUPER ALT, mouse:272, pseudo"
# hyprctl keyword "$un"bind "SUPER SHIFT CTRL, mouse:272, your_command_here"
# hyprctl keyword "$un"bind "SUPER SHIFT ALT, mouse:272, your_command_here"
hyprctl keyword "$un"bind "SUPER CTRL ALT, mouse:272, togglesplit"
hyprctl keyword "$un"bind "SUPER SHIFT CTRL ALT, mouse:272, movetoworkspace, 0"
hyprctl keyword "$un"bind$m "SUPER, mouse:272, movewindow"
