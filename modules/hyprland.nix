{ config, pkgs, ... }:

let
  privatePath = if builtins.pathExists ../private/private.json
                then ../private/private.json
                else ../templates/private/private.json;
  private = builtins.fromJSON (builtins.readFile privatePath);
  mkSubmap = { name, prev, next }: {
    settings = {
      bind = let
        alphabet = ["a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m" "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z"];
        sendshortcutBindings = map (letter: ", ${letter}, sendshortcut, ${name}, ${letter},") alphabet;
        navigationBindings = [
          ", XF86AudioRewind, submap, ${prev}"
          ", XF86AudioForward, submap, ${next}"
        ];
      in sendshortcutBindings ++ navigationBindings;
    };
  };

  modMap = {
    SHIFT = 1;
    CTRL = 4;
    ALT = 8;
    SUPER = 64;
  };

  actions = import ./actions.nix;

  modStrMap = {
    "0" = "";
    "1" = "SHIFT";
    "4" = "CTRL";
    "5" = "SHIFT CTRL";
    "8" = "ALT";
    "9" = "SHIFT ALT";
    "12" = "CTRL ALT";
    "13" = "SHIFT CTRL ALT";
    "64" = "SUPER";
    "65" = "SUPER SHIFT";
    "68" = "SUPER CTRL";
    "69" = "SUPER SHIFT CTRL";
    "72" = "SUPER ALT";
    "73" = "SUPER SHIFT ALT";
    "76" = "SUPER CTRL ALT";
    "77" = "SUPER SHIFT CTRL ALT";
  };

  modToStr = mod:
    if builtins.isInt mod
      then modStrMap.${toString mod} or (toString mod)
      else mod;

  windowRules = {
    sw = "[float; size ${toString (private.screen.width / 2)} ${toString (private.screen.height / 2)}]";
    swl = "[float; size ${toString private.screen.width} ${toString (private.screen.height / 2)}]";
    small_win = "[float; pin; size 300 300; move ${toString (private.screen.width - 300 - 30)} ${toString 440}]";
    large_win = "[float; pin; size 800 300; move ${toString (private.screen.width - 800 - 30)} ${toString (440 - 300)}]";
  };

  actionWindowRules = {
    "voice commands" = "sw";
    "select speeches" = "sw";
    "polish speeches" = "sw";
    "toggle unicode input" = "sw";
    "toggle clipboard" = "sw";
    "select webpage" = "sw";
    "select theme" = "sw";
    "execute command" = "swl";
    "rename workspace" = "sw";
    "save webpage" = "sw";
    "save window group" = "sw";
    "sync config" = "sw";
    "reload home config" = "swl";
    "rebuild NixOS config" = "swl";
    "toggle window info" = "sw";
  };

  mkBind = args:
    let
      len = builtins.length args;
      firstArg = builtins.elemAt args 0;
      secondArg = if len >= 2 then builtins.elemAt args 1 else null;

      isGestureWithMod = len >= 3 && builtins.isInt firstArg && builtins.isList secondArg;
      isGestureNoMod = len >= 2 && builtins.isList firstArg;
      isGesture = isGestureWithMod || isGestureNoMod;
    in
      if isGesture
        then mkGestureBind args
        else mkKeyBind args;

  mkKeyBind = args:
    let
      len = builtins.length args;
      modRaw = if len == 2 then 0 else builtins.elemAt args 0;
      key = if len == 2 then builtins.elemAt args 0 else builtins.elemAt args 1;
      action = if len == 2 then builtins.elemAt args 1 else builtins.elemAt args 2;

      modStr = modToStr modRaw;

      hasDesc = !builtins.isList action && actions ? ${action};

      resolved = if builtins.isList action
        then action
        else actions.${action} or action;

      ruleName = if hasDesc then (actionWindowRules.${action} or null) else null;
      rulePrefix = if ruleName != null then "${windowRules.${ruleName}} " else "";

      actionStr = if builtins.isList resolved
        then builtins.concatStringsSep ", " resolved
        else "exec, ${rulePrefix}${resolved}";
    in
      if hasDesc
        then "${modStr}, ${key}, ${action}, ${actionStr}"
        else "${modStr}, ${key}, ${actionStr}";

  mkGestureBind = args:
    let
      len = builtins.length args;
      firstArg = builtins.elemAt args 0;

      hasMod = builtins.isInt firstArg;
      modRaw = if hasMod then firstArg else 0;
      gestureParams = if hasMod then builtins.elemAt args 1 else firstArg;
      action = if hasMod then builtins.elemAt args 2 else builtins.elemAt args 1;

      fingers = builtins.elemAt gestureParams 0;
      gesture = builtins.elemAt gestureParams 1;

      modStr = modToStr modRaw;
      modPrefix = if modRaw != 0 then "mod: ${modStr}, " else "";

      hasDesc = !builtins.isList action && actions ? ${action};

      resolved = if builtins.isList action
        then action
        else actions.${action} or action;

      actionStr = if builtins.isList resolved
        then "dispatcher, ${builtins.concatStringsSep ", " resolved}"
        else "dispatcher, exec, ${resolved}";
    in
      "${toString fingers}, ${gesture}, ${modPrefix}${actionStr}";

  keyboardExtraBindd =
    let
      digitBindings = builtins.genList (n:
        mkBind [64 (toString n) "speech ${toString n}"]
      ) 10;

      voiceCommandBindings = builtins.genList (n:
        mkBind [65 (toString n) "voice command ${toString n}"]
      ) 10;

      otherBindings = [
        (mkBind [64 "Delete" "enter kill mode"])
        (mkBind [64 "left" "move focus left"])
        (mkBind [64 "right" "move focus right"])
        (mkBind [64 "up" "move focus up"])
        (mkBind [64 "down" "move focus down"])
        (mkBind [64 "prior" "previous workspace"])
        (mkBind [64 "next" "next workspace"])
        (mkBind [65 "left" "move window left"])
        (mkBind [65 "right" "move window right"])
        (mkBind [65 "up" "move window up"])
        (mkBind [65 "down" "move window down"])
        (mkBind [65 "prior" "move to previous workspace"])
        (mkBind [65 "next" "move to next workspace"])
        (mkBind [68 "left" "move window/group left"])
        (mkBind [68 "right" "move window/group right"])
        (mkBind [68 "up" "move window/group up"])
        (mkBind [68 "down" "move window/group down"])
        (mkBind [64 "insert" "notify layer switch"])
        (mkBind [64 "grave" "enter clean mode"])
        (mkBind [64 "apostrophe" "capture full screen"])
        (mkBind [65 "apostrophe" "record full screen"])
        (mkBind [68 "apostrophe" "capture active window"])
        (mkBind [69 "apostrophe" "record active window"])
        (mkBind [72 "apostrophe" "capture selected area"])
        (mkBind [73 "apostrophe" "record selected area"])
        (mkBind [76 "apostrophe" "capture selected window"])
        (mkBind [77 "apostrophe" "record selected window"])
        (mkBind [64 "return" "open wifi control"])
        (mkBind [65 "return" "open bluetooth control"])
        (mkBind [64 "tab" "open config list with nvim"])
        (mkBind [65 "tab" "open config list with yazi"])
        (mkBind [68 "tab" "open config with claude"])
        (mkBind [69 "tab" "sync config"])
        (mkBind [72 "tab" "edit secret file"])
        (mkBind [76 "tab" "reload home config"])
        (mkBind [77 "tab" "rebuild NixOS config"])
        (mkBind [64 "F1" "open Desktop"])
        (mkBind [64 "F2" "open Downloads"])
        (mkBind [64 "F3" "open Documents"])
        (mkBind [64 "F4" "open Public"])
        (mkBind [64 "F5" "open Music"])
        (mkBind [64 "F6" "open Pictures"])
        (mkBind [64 "F7" "open Videos"])
        (mkBind [64 "F8" "open Templates"])
        (mkBind [64 "F9" "open home"])
        (mkBind [64 "F10" "open root"])
      ];
    in digitBindings ++ voiceCommandBindings ++ otherBindings;

  testBindd = [
    (mkBind [64 "equal" "open terminal"])
    (mkBind [64 "e" "open editor"])
    (mkBind [64 "f" "open file manager"])
    (mkBind [64 "m" "open system monitor"])
    (mkBind [64 "l" "toggle launcher"])
    (mkBind [64 "b" "open browser"])
    (mkBind [64 "bracketleft" "open Jupyter"])
    (mkBind [64 "bracketright" "open Mathematica"])
    (mkBind [64 "v" "select speeches"])
    (mkBind [65 "v" "polish speeches"])
    (mkBind [64 "u" "toggle unicode input"])
    (mkBind [64 "c" "voice commands"])
    (mkBind [64 "h" "toggle clipboard"])
    (mkBind [64 "j" "explain questions"])
    (mkBind [64 "g" "check system log"])
    (mkBind [64 "n" "toggle pinned windows"])
    (mkBind [64 "d" "view daily card"])
    (mkBind [64 "w" "toggle status bar"])
    (mkBind [64 "z" "toggle magnifier"])
    (mkBind [64 "a" "toggle annotator"])
    (mkBind [64 "p" "select webpage"])
    (mkBind [64 "x" "execute command"])
    (mkBind [64 "r" "rename workspace"])
    (mkBind [64 "s" "save webpage"])
    (mkBind [65 "s" "save window group"])
    (mkBind [64 "o" "reopen window group"])
    (mkBind [64 "t" "select theme"])
    (mkBind [64 "i" "open claude code"])
  ];

  mouseBindd = [
    (mkBind [65 "mouse:272" "toggle fullscreen"])
    (mkBind [68 "mouse:272" "toggle floating"])
    (mkBind [72 "mouse:272" "toggle pseudo"])
    (mkBind [69 "mouse:272" "pin window"])
    (mkBind [73 "mouse:272" "toggle split"])
    (mkBind [76 "mouse:272" "move out of group"])
    (mkBind [77 "mouse:272" "toggle group"])
    (mkBind [65 "mouse:273" "kill active window"])
    (mkBind [68 "mouse:273" "focus empty"])
    (mkBind [72 "mouse:273" "toggle scratchpad"])
    (mkBind [69 "mouse:273" "move to empty"])
    (mkBind [73 "mouse:273" "move to scratchpad"])
    (mkBind [76 "mouse:273" "toggle window info"])
    (mkBind [77 "mouse:273" "swap workspaces"])
    (mkBind [64 "mouse:274" "paste focused content"])
    (mkBind [65 "mouse:274" "type focused content"])
    (mkBind [68 "mouse:274" "open focused content"])
    (mkBind [72 "mouse:274" "generate focused content"])
    (mkBind [73 "mouse:274" "execute focused content"])
    (mkBind [77 "mouse:274" "copy focused content"])
    (mkBind [64 "mouse_down" "previous workspace"])
    (mkBind [64 "mouse_up" "next workspace"])
    (mkBind [65 "mouse_down" "move to previous workspace"])
    (mkBind [65 "mouse_up" "move to next workspace"])
    (mkBind [68 "mouse_down" "previous window"])
    (mkBind [68 "mouse_up" "next window"])
    (mkBind [72 "mouse_down" "focus backward in group"])
    (mkBind [72 "mouse_up" "focus forward in group"])
    (mkBind [69 "mouse_down" "swap with previous window"])
    (mkBind [69 "mouse_up" "swap with next window"])
    (mkBind [73 "mouse_down" "move backward in group"])
    (mkBind [73 "mouse_up" "move forward in group"])
  ];

  keyboardCoreBindd = [
    (mkBind [72 "redo" "increase speaker volume"])
    (mkBind [72 "undo" "decrease speaker volume"])
    (mkBind [73 "redo" "increase microphone volume"])
    (mkBind [73 "undo" "decrease microphone volume"])
    (mkBind [68 "redo" "increase screen brightness"])
    (mkBind [68 "undo" "decrease screen brightness"])
    (mkBind [69 "redo" "next media track"])
    (mkBind [69 "undo" "previous media track"])
    (mkBind [1 "pause" "send pause key"])
  ];

  bindelBindings = [
    (mkBind ["XF86AudioRaiseVolume" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+"])
    (mkBind ["XF86AudioLowerVolume" "wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"])
    (mkBind ["XF86AudioMute" "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"])
    (mkBind ["XF86AudioMicMute" "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"])
    (mkBind ["XF86MonBrightnessUp" "brightnessctl s 1%+"])
    (mkBind ["XF86MonBrightnessDown" "brightnessctl s 1%-"])
    (mkBind ["XF86DisplayToggle" "hyprctl dispatch dpms toggle"])
  ];

  bindlBindings = [
    (mkBind ["XF86AudioNext" "playerctl next"])
    (mkBind ["XF86AudioPause" "playerctl play-pause"])
    (mkBind ["XF86AudioPlay" "playerctl play-pause"])
    (mkBind ["XF86AudioPrev" "playerctl previous"])
  ];

in {
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {

    input = {
      kb_layout = "us";
      kb_variant = "";
      kb_model = "";
      kb_options = "";
      kb_rules = "";
      follow_mouse = 1;
      float_switch_override_focus = 0;
      touchpad.natural_scroll = true;
      sensitivity = 0;
    };

    general = {
      gaps_in = 5;
      gaps_out = 20;
      border_size = 2;
      "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
      "col.inactive_border" = "rgba(595959aa)";
      layout = "dwindle";
      allow_tearing = false;
    };

    decoration = {
      rounding = 10;
      inactive_opacity = 0.5;
      blur = {
        enabled = true;
        size = 3;
        passes = 1;
        ignore_opacity = true;
      };
    };

    animations = {
      enabled = true;
      bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
      ];
    };

    dwindle = {
      pseudotile = true;
      preserve_split = true;
    };

    master = {};

    misc = {
      force_default_wallpaper = -1;
    };

    device = {
      name = "epic-mouse-v1";
      sensitivity = -0.5;
    };

    bindm = [
      "SUPER, mouse:272, movewindow"
      "SUPER, mouse:273, resizewindow"
    ];

    bindd = mouseBindd ++ keyboardCoreBindd ++ keyboardExtraBindd ++ testBindd;

    # Mod-only binds, work well with my Mir T5+ keyboard layer 1
    binddr = [
      (mkBind [64 "SUPER_L" "open terminal"])
      (mkBind [65 "SUPER_L" "open editor"])
      (mkBind [72 "SUPER_L" "open file manager"])
      (mkBind [68 "SUPER_L" "open system monitor"])
      (mkBind [73 "SUPER_L" "toggle launcher"])
      (mkBind [69 "SUPER_L" "open browser"])
      (mkBind [76 "SUPER_L" "open Jupyter"])
      (mkBind [77 "SUPER_L" "open Mathematica"])
      (mkBind [65 "SHIFT_L" "voice commands"])
      (mkBind [9 "SHIFT_L" "select speeches"])
      (mkBind [5 "SHIFT_L" "polish speeches"])
      (mkBind [73 "SHIFT_L" "toggle unicode input"])
      (mkBind [69 "SHIFT_L" "toggle clipboard"])
      (mkBind [13 "SHIFT_L" "explain questions"])
      (mkBind [68 "CONTROL_L" "check system log"])
      (mkBind [5 "CONTROL_L" "toggle pinned windows"])
      (mkBind [12 "CONTROL_L" "view daily card"])
      (mkBind [69 "CONTROL_L" "toggle status bar"])
      (mkBind [76 "CONTROL_L" "toggle magnifier"])
      (mkBind [13 "CONTROL_L" "toggle annotator"])
      (mkBind [72 "ALT_L" "select webpage"])
      (mkBind [9 "ALT_L" "execute command"])
      (mkBind [12 "ALT_L" "rename workspace"])
      (mkBind [73 "ALT_L" "save webpage"])
      (mkBind [76 "ALT_L" "save window group"])
      (mkBind [13 "ALT_L" "reopen window group"])
      (mkBind [77 "ALT_L" "select theme"])
      (mkBind [64 "SUPER_R" "open claude code"])
    ];

    # Fit well with knob turning (as undo & redo) of my Mir T5+ keyboard layer 1
    bind = [
      (mkBind ["redo" ["sendshortcut" "" "down" ""]])
      (mkBind ["undo" ["sendshortcut" "" "up" ""]])
      (mkBind [1 "redo" ["sendshortcut" "" "right" ""]])
      (mkBind [1 "undo" ["sendshortcut" "" "left" ""]])
      (mkBind [8 "redo" ["sendshortcut" "" "next" ""]])
      (mkBind [8 "undo" ["sendshortcut" "" "prior" ""]])
      (mkBind [9 "redo" ["sendshortcut" "" "end" ""]])
      (mkBind [9 "undo" ["sendshortcut" "" "home" ""]])
      (mkBind [4 "redo" ["sendshortcut" "" "delete" ""]])
      (mkBind [4 "undo" ["sendshortcut" "" "backspace" ""]])
      (mkBind [5 "redo" ["sendshortcut" "" "code:36" ""]])
      (mkBind [5 "undo" ["sendshortcut" "" "code:23" ""]])
      (mkBind [64 "redo" ["sendshortcut" "" "redo" ""]])
      (mkBind [64 "undo" ["sendshortcut" "" "undo" ""]])
      (mkBind ["XF86AudioForward" ["submap" "Shift"]])
      (mkBind ["XF86AudioRewind" ["submap" "Shift Ctrl Alt"]])
    ];

    binddl = [
      (mkBind [8 "pause" "toggle speaker mute"])
      (mkBind [9 "pause" "toggle microphone mute"])
      (mkBind [4 "pause" "toggle display power"])
      (mkBind [5 "pause" "toggle media playback"])
      (mkBind [64 "pause" "lock screen"])
      (mkBind [65 "pause" "exit session"])
      (mkBind [72 "pause" "suspend system"])
      (mkBind [68 "pause" "hibernate system"])
      (mkBind [76 "pause" "reboot system"])
      (mkBind [77 "pause" "poweroff system"])
    ];

    # Laptop multimedia keys for volume and LCD brightness
    bindel = bindelBindings;

    # Requires playerctl
    bindl = bindlBindings;

    monitor = [
      "Virtual-1, ${toString private.screen.width}x${toString private.screen.height}@60.00, auto, 1"
      "eDP-1, preferred, auto, 1, mirror, Virtual-1"
      "DP-3, preferred, auto, 1, mirror, Virtual-1"
      "HDMI-A-1, preferred, auto, 1, mirror, Virtual-1"
    ];

    workspace = "name:, monitor:Virtual-1, default:true";

    windowrule = [
      "pseudo on, match:class ^(fcitx)$"
      "float on, match:title ^(Meeting)$"
      "float on, match:class ^(hyprland-share-picker)$"
      "pseudo on, match:class ^(hyprland-share-picker)$"
      "suppress_event maximize, match:class .*"
      "float on, match:class ^(com.wolfram.Wolfram.*)$, match:title ^(WolframNB)$"
      "group barred, match:class ^(com.wolfram.Wolfram.*)$, match:title ^(WolframNB)$"
      "group barred, match:class ^(wechat)$, match:title ^(朋友圈)$"
      "pin on, match:class ^(qqmusic)$, match:title ^(歌词)$"
      "float on, match:title ^(Progress Window)$, match:class ^python3$"
      "pin on, match:title ^(Progress Window)$, match:class ^python3$"
      "no_initial_focus on, match:title ^(Progress Window)$, match:class ^python3$"
      "workspace name:🖧, match:class ^(Gnome-boxes)$"
      "workspace name:󰢹, match:class ^(sdl-freerdp3)$"
      "workspace name:󰍡, match:class ^(QQ|wechat|Feishu|wemeetapp)$"
      "workspace name:, match:class ^(qqmusic)$"
      "workspace name:, match:class ^(steam*)$"
      "workspace special:󰬯, match:class ^(crystal-board)$"
    ];

    "execr-once" = [
      "systemctl --user start nixos-fake-graphical-session.target"
      "sleep 1; ffplay ~/gnosia.ogg -nodisp -autoexit"
      "fcitx5"
      "QT_QPA_PLATFORMTHEME=gtk3 hyprpolkitagent"
      "wl-paste -w cliphist store"
      "wl-paste -w wl-copy -p"
      "pw-record ~/Music/always_on.wav"
      "wf-recorder -yf ~/Videos/always_on.mkv -a=`pactl get-default-sink`.monitor -c h264_vaapi"
      "solar_progress.py"
      "get_vitals.py"
      "socket.sh"
      "strip_exports.sh"
      "phone_automation.sh"
    ];

    "exec-once" = [
      "[workspace name:󰔊 silent] while true; do run_project.sh SenseStream; done"
      "[workspace name:󰋼 silent fullscreen] xdg-open 'http://127.0.0.1:9090/ui/'"
      "[workspace special: silent] kitty --listen-on unix:$XDG_RUNTIME_DIR/agent claude"
      "${windowRules.small_win} $te watch -n 1 \"sqlite3 ~/.log.db \\\"SELECT (id % 10), substr(content, 1, 10) FROM speech WHERE id > (SELECT MAX(id) FROM speech) - 10 ORDER BY (id % 10);\\\"\""
      "${windowRules.large_win} $teh sh -c 'while true; do clear; cat ~/README.md; inotifywait -q -e modify ~/README.md; done'"
    ];

    gesture = [
      (mkBind [[2 "pinch"] "toggle fullscreen"])
      (mkBind [[3 "pinch"] ["close"]])
      (mkBind [65 [2 "pinch"] "toggle fullscreen"])
      (mkBind [68 [2 "pinch"] "toggle floating"])
      (mkBind [72 [2 "pinch"] "toggle pseudo"])
      (mkBind [69 [2 "pinch"] "pin window"])
      (mkBind [73 [2 "pinch"] "toggle split"])
      (mkBind [76 [2 "pinch"] "move out of group"])
      (mkBind [77 [2 "pinch"] "toggle group"])
      (mkBind [65 [3 "pinch"] ["close"]])
      (mkBind [68 [3 "pinch"] "focus empty"])
      (mkBind [72 [3 "pinch"] "toggle scratchpad"])
      (mkBind [69 [3 "pinch"] "move to empty"])
      (mkBind [73 [3 "pinch"] "move to scratchpad"])
      (mkBind [76 [3 "pinch"] "toggle window info"])
      (mkBind [77 [3 "pinch"] "swap workspaces"])
      (mkBind [64 [4 "pinch"] "paste focused content"])
      (mkBind [65 [4 "pinch"] "type focused content"])
      (mkBind [68 [4 "pinch"] "open focused content"])
      (mkBind [72 [4 "pinch"] "generate focused content"])
      (mkBind [73 [4 "pinch"] "execute focused content"])
      (mkBind [77 [4 "pinch"] "copy focused content"])
      (mkBind [[3 "horizontal"] ["workspace"]])
      (mkBind [[3 "up"] ["movetoworkspace" "e-1"]])
      (mkBind [[3 "down"] ["movetoworkspace" "e+1"]])
      (mkBind [[4 "left"] ["changegroupactive" "b"]])
      (mkBind [[4 "right"] ["changegroupactive" "f"]])
      (mkBind [[4 "up"] ["movegroupwindow" "b"]])
      (mkBind [[4 "down"] ["movegroupwindow" "f"]])
    ];
  };

  # All submaps and their binds below are for Mir T5+ keyboard layer 4
  submaps =
    let
      submapOrder = [
        "Shift"
        "Ctrl"
        "Alt"
        "Shift Ctrl"
        "Shift Alt"
        "Ctrl Alt"
        "Shift Ctrl Alt"
      ];

      mkSubmapChain = names:
        let
          len = builtins.length names;
          mkSubmapEntry = i:
            let
              name = builtins.elemAt names i;
              prev = if i == 0 then "reset" else builtins.elemAt names (i - 1);
              next = if i == len - 1 then "reset" else builtins.elemAt names (i + 1);
            in {
              name = name;
              value = mkSubmap { inherit name prev next; };
            };
        in builtins.listToAttrs (builtins.genList mkSubmapEntry len);
    in
      mkSubmapChain submapOrder // {
        # Clean submap from keyboard_extra.conf
        clean = {
          settings.bind = [
            "SUPER, grave, submap, reset"
            ", catchall, exec, hyprctl notify -1 1000 \"rgb(ff1ea3)\" \"Try again after unlocking the map.\""
          ];
        };
      };
  };
}
