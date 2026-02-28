let
  te = "alacritty -e";
  env = "source path.sh;";
in {
  "open terminal" = "${env} ${te} sh -c 'exec script -qf $XDG_RUNTIME_DIR/$$.log'";
  "open editor" = "${env} ${te} nvim";
  "open file manager" = "${env} ${te} yazi";
  "open system monitor" = "${te} btop";
  "toggle launcher" = "pkill wofi || wofi";
  "open browser" = "google-chrome-stable";
  "open Jupyter" = "${env} ${te} euporie-notebook main.ipynb";
  "open Mathematica" = "${env} mathematica-notebook main.nb";

  "voice commands" = "pkill speech.sh || ${te} speech.sh simple -c";
  "select speeches" = "pkill speech.sh || ${te} speech.sh simple";
  "polish speeches" = "pkill speech.sh || ${te} speech.sh complex";
  "toggle unicode input" = "pkill unicode.sh || ${te} unicode.sh";
  "toggle clipboard" = "pkill clipboard.sh || ${te} clipboard.sh";
  "explain questions" = "xdg-open `wl-paste -p`";

  "check system log" = ["togglespecialworkspace" "󰋼"];
  "toggle pinned windows" = "toggle_pinned_windows.sh";
  "view daily card" = ["togglespecialworkspace" "󰘹"];
  "toggle status bar" = "pkill -SIGUSR1 waybar";
  "toggle magnifier" = "pkill woomer || woomer";
  "toggle annotator" = "pkill crystal-board || crystal-board";

  "select webpage" = "${env} pkill explore.sh || ${te} explore.sh";
  "select theme" = "${env} pkill select_theme.sh || ${te} select_theme.sh";
  "execute command" = "pkill execs.sh || ${te} execs.sh";
  "rename workspace" = "pkill rename.sh || ${te} rename.sh";
  "save webpage" = "${env} save.sh";
  "save window group" = "${env} pkill save_windows.sh || ${te} save_windows.sh";
  "reopen window group" = "${env} ${te} reopen_windows.sh";
  "open claude code" = "${env} ${te} launch_claude.sh";

  "increase speaker volume" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+";
  "decrease speaker volume" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
  "increase microphone volume" = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1%+";
  "decrease microphone volume" = "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 1%-";
  "increase screen brightness" = "brightnessctl s 1%+";
  "decrease screen brightness" = "brightnessctl s 1%-";
  "next media track" = "playerctl next";
  "previous media track" = "playerctl previous";
  "send pause key" = ["sendshortcut" "" "pause" ""];

  "toggle speaker mute" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
  "toggle microphone mute" = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
  "toggle display power" = "hyprctl dispatch dpms toggle";
  "toggle media playback" = "playerctl play-pause";
  "lock screen" = "hyprlock";
  "exit session" = ["exit"];
  "suspend system" = "systemctl suspend";
  "hibernate system" = "systemctl hibernate";
  "reboot system" = "systemctl reboot";
  "poweroff system" = "systemctl poweroff";

  "speech 0" = "speech.sh 0";
  "speech 1" = "speech.sh 1";
  "speech 2" = "speech.sh 2";
  "speech 3" = "speech.sh 3";
  "speech 4" = "speech.sh 4";
  "speech 5" = "speech.sh 5";
  "speech 6" = "speech.sh 6";
  "speech 7" = "speech.sh 7";
  "speech 8" = "speech.sh 8";
  "speech 9" = "speech.sh 9";

  "voice command 0" = "speech.sh 0 -c";
  "voice command 1" = "speech.sh 1 -c";
  "voice command 2" = "speech.sh 2 -c";
  "voice command 3" = "speech.sh 3 -c";
  "voice command 4" = "speech.sh 4 -c";
  "voice command 5" = "speech.sh 5 -c";
  "voice command 6" = "speech.sh 6 -c";
  "voice command 7" = "speech.sh 7 -c";
  "voice command 8" = "speech.sh 8 -c";
  "voice command 9" = "speech.sh 9 -c";

  "move focus left" = ["movefocus" "l"];
  "move focus right" = ["movefocus" "r"];
  "move focus up" = ["movefocus" "u"];
  "move focus down" = ["movefocus" "d"];
  "previous workspace" = ["workspace" "e-1"];
  "next workspace" = ["workspace" "e+1"];
  "move window left" = ["movewindow" "l"];
  "move window right" = ["movewindow" "r"];
  "move window up" = ["movewindow" "u"];
  "move window down" = ["movewindow" "d"];
  "move to previous workspace" = ["movetoworkspace" "e-1"];
  "move to next workspace" = ["movetoworkspace" "e+1"];
  "move window/group left" = ["movewindoworgroup" "l"];
  "move window/group right" = ["movewindoworgroup" "r"];
  "move window/group up" = ["movewindoworgroup" "u"];
  "move window/group down" = ["movewindoworgroup" "d"];

  "enter kill mode" = "hyprctl kill";
  "notify layer switch" = "hyprctl notify -1 1000 \"rgb(ff1ea3)\" \"Layer Switched.\"";
  "enter clean mode" = ["submap" "clean"];

  "capture full screen" = "record.sh capture full";
  "record full screen" = "record.sh record full";
  "capture active window" = "record.sh capture window-active";
  "record active window" = "record.sh record window-active";
  "capture selected area" = "record.sh capture select";
  "record selected area" = "record.sh record select";
  "capture selected window" = "record.sh capture window-select";
  "record selected window" = "record.sh record window-select";

  "open wifi control" = "pkill iwctl || ${te} iwctl";
  "open bluetooth control" = "pkill bluetoothctl || ${te} bluetoothctl";

  "open config list with nvim" = "${te} sh -c 'cd ~/.config/home-manager; config=\"`git ls-files | fzf -m`\" && nvim $config -O'";
  "open config list with yazi" = "${te} sh -c 'cd ~/.config/home-manager; config=\"`git ls-files | fzf -m`\" && yazi $config'";
  "open config with claude" = "${te} sh -c 'cd ~/.config/home-manager; config=\"`git ls-files | fzf`\" && claude \"@$config\"'";
  "sync config" = "${te} sync_mirror.sh";
  "edit secret file" = "${te} sops edit ~/.config/home-manager/secrets/secrets.enc.yaml";
  "reload home config" = "${te} sh -c 'home-manager switch | less; hyprctl reload'";
  "rebuild NixOS config" = "${te} sudo rebuild_nixos.sh";

  "open Desktop" = "${te} yazi Desktop";
  "open Downloads" = "${te} yazi Downloads";
  "open Documents" = "${te} yazi Documents";
  "open Public" = "${te} yazi Public";
  "open Music" = "${te} yazi Music";
  "open Pictures" = "${te} yazi Pictures";
  "open Videos" = "${te} yazi Videos";
  "open Templates" = "${te} yazi Templates";
  "open home" = "${te} yazi ~";
  "open root" = "${te} yazi /";

  "toggle fullscreen" = ["fullscreen"];
  "toggle floating" = ["togglefloating"];
  "toggle pseudo" = ["pseudo"];
  "pin window" = ["pin"];
  "toggle split" = ["togglesplit"];
  "move out of group" = ["moveoutofgroup"];
  "toggle group" = ["togglegroup"];
  "kill active window" = ["killactive"];
  "focus empty" = ["focusworkspaceoncurrentmonitor" "empty"];
  "toggle scratchpad" = ["togglespecialworkspace" "scratchpad"];
  "move to empty" = ["movetoworkspace" "empty"];
  "move to scratchpad" = ["movetoworkspacesilent" "special:scratchpad"];
  "toggle window info" = "hyprctl activewindow -j > $XDG_RUNTIME_DIR/info.json; pkill show.sh || ${te} show.sh";
  "swap workspaces" = ["swapactiveworkspaces" "DP-3 HDMI-A-1"];

  "paste focused content" = "focus.sh paste";
  "type focused content" = "focus.sh type";
  "open focused content" = "focus.sh open";
  "generate focused content" = "${env} focus.sh generate";
  "execute focused content" = "focus.sh execute";
  "copy focused content" = "focus.sh copy";

  "previous window" = ["cyclenext" "prev"];
  "next window" = ["cyclenext"];
  "focus backward in group" = ["changegroupactive" "b"];
  "focus forward in group" = ["changegroupactive" "f"];
  "swap with previous window" = ["swapnext" "prev"];
  "swap with next window" = ["swapnext"];
  "move backward in group" = ["movegroupwindow" "b"];
  "move forward in group" = ["movegroupwindow" "f"];
}
