{ config, lib, pkgs, ... }:

let
  style = ''
    /* Global font and icon setup */
    * {
      /* `otf-font-awesome` is required to be installed for icons */
      font-family: FontAwesome, Roboto, Helvetica, Arial, sans-serif;
      font-size: 15px;
      color: #ffffff;
    }

    /* Main window */
    window#waybar {
      background-color: transparent;
      border-bottom: 0;
    }

    window#waybar.hidden {
      opacity: 0.2;
    }

    /* Basic button styling */
    button {
      /* Use box-shadow instead of border so the text isn't offset */
      box-shadow: inset 0 -3px transparent;
      /* Avoid rounded borders under each button name */
      border: none;
      border-radius: 0;
    }

    button:hover {
      background: inherit;
      box-shadow: inset 0 -3px #ffffff;
    }

    /* Workspace buttons */
    #workspaces button {
      padding: 0 5px;
      background-color: rgba(255, 255, 255, 0.1);
      color: #ffffff;
      border-radius: 8px;
    }

    #workspaces button:hover {
      background: rgba(0, 0, 0, 0.2);
    }

    #workspaces button.active {
      background-color: rgba(255, 255, 255, 0.25);
      box-shadow: inset 0 -3px #ffffff;
      border-radius: 8px;
    }

    #workspaces button.urgent {
      background-color: #eb4d4b;
    }

    /* Mode indicator (not used in current config but kept for completeness) */
    #mode {
      background-color: transparent;
      box-shadow: inset 0 -3px #ffffff;
    }

    /* Window and workspaces margins */
    #window,
    #workspaces {
      margin: 0 4px;
    }

    /* If workspaces is the leftmost module, omit left margin */
    .modules-left > widget:first-child > #workspaces {
      margin-left: 0;
    }

    /* If workspaces is the rightmost module, omit right margin */
    .modules-right > widget:last-child > #workspaces {
      margin-right: 0;
    }

    /* Animation for critical battery */
    @keyframes blink {
      to {
        background-color: #ffffff;
        color: #000000;
      }
    }

    /* Common module styling - All modules get this base styling */
    #clock,
    #battery,
    #cpu,
    #memory,
    #disk,
    #temperature,
    #backlight,
    #network,
    #pulseaudio,
    #custom-media,
    #tray,
    #mode,
    #idle_inhibitor,
    #scratchpad,
    #power-profiles-daemon,
    #mpd,
    #custom-count_words,
    #custom-crypto_assets,
    #custom-solar_status,
    #custom-body_temperature,
    #custom-heart_rate,
    #custom-blood_oxygen,
    #custom-blood_pressure,
    #custom-steps,
    #custom-battery_level {
      background-color: rgba(255, 255, 255, 0.15);
      border-radius: 15px;
      padding: 0 12px;
    }

    /* Menu styling */
    menu {
      border-radius: 15px;
      background: #161320;
      color: #B5E8E0;
    }

    menuitem {
      border-radius: 15px;
    }

    /* Module-specific colors (from user modifications) */

    #clock {
    }

    #battery {
      color: #ffffff;
    }

    #battery.charging, #battery.plugged {
      color: #26A65B;
    }

    #battery.critical:not(.charging) {
      color: #f53c3c;
      animation-name: blink;
      animation-duration: 0.5s;
      animation-timing-function: steps(12);
      animation-iteration-count: infinite;
      animation-direction: alternate;
    }

    #power-profiles-daemon.performance {
      color: #f53c3c;
    }

    #power-profiles-daemon.balanced {
      color: #2980b9;
    }

    #power-profiles-daemon.power-saver {
      color: #2ecc71;
    }

    #cpu {
      color: #2ecc71;
    }

    #memory {
      color: #9b59b6;
    }

    #disk {
      color: #964B00;
    }

    #network {
      color: #2980b9;
    }

    #network.disconnected {
      color: #f53c3c;
    }

    #pulseaudio {
      color: #f1c40f;
    }

    #pulseaudio.muted {
      color: #90b1b1;
    }

    #temperature {
      color: #f0932b;
    }

    #temperature.critical {
      color: #eb4d4b;
    }

    #idle_inhibitor {
      color: #2d3436;
    }

    #idle_inhibitor.activated {
      color: #ffffff;
    }

    /* Tray styling */
    #tray {
      background-color: transparent;
    }

    #tray > .passive {
      -gtk-icon-effect: dim;
    }

    #tray > .needs-attention {
      -gtk-icon-effect: highlight;
      background-color: #eb4d4b;
    }

    /* Scratchpad */
    #scratchpad {
      background: rgba(0, 0, 0, 0.2);
    }

    #scratchpad.empty {
      background-color: transparent;
    }

    /* Privacy indicators */
    #privacy {
      padding: 0;
    }

    #privacy-item {
      padding: 0 5px;
      color: white;
    }

    #privacy-item.screenshare {
      background-color: #cf5700;
    }

    #privacy-item.audio-in {
      background-color: #1ca000;
    }

    #privacy-item.audio-out {
      background-color: #0069d4;
    }

    /* Language indicator */
    #language {
      background: #00b093;
      color: #740864;
      padding: 0 5px;
      margin: 0 5px;
      min-width: 16px;
    }

    /* Keyboard state */
    #keyboard-state {
      background: transparent;
      color: #ffffff;
      padding: 0 0px;
      margin: 0 5px;
      min-width: 16px;
    }

    #keyboard-state > label {
      padding: 0 5px;
    }

    #keyboard-state > label.locked {
      background: rgba(0, 0, 0, 0.2);
    }
  '';
in
{
  programs.waybar = {
    enable = true;

    settings = {
      top = {
        position = "top";
        height = 30;
        spacing = 4;
        "modules-left" = [
          "hyprland/workspaces"
          "hyprland/submap"
          "custom/media"
        ];
        "modules-center" = [ "hyprland/window" ];
        "modules-right" = [
          "mpd"
          "idle_inhibitor"
          "pulseaudio"
          "network"
          "power-profiles-daemon"
          "cpu"
          "memory"
          "disk"
          "temperature"
          "backlight"
          "battery"
          "battery#bat2"
          "clock"
          "tray"
        ];

        "hyprland/workspaces" = {
          "disable-scroll" = true;
          "all-outputs" = true;
          "warp-on-scroll" = false;
          format = "{name}";
        };

        "hyprland/submap" = {
          format = "✌️ {}";
          tooltip = false;
        };

        "keyboard-state" = {
          numlock = true;
          capslock = true;
          format = "{name} {icon}";
          "format-icons" = {
            locked = "";
            unlocked = "";
          };
        };

        "hyprland/window" = {
          format = "{class} {title}";
          rewrite = {
            "(.*) — Mozilla Firefox" = "  $1";
            "nyxt Nyxt - (.*)" = "  $1";
            "Alacritty ~" = " ";
            "Alacritty Yazi(.*)" = "󰙅 $1";
            "Alacritty euporie-notebook" = "  ";
            "com.wolfram.Wolfram.14.3 (.*) - Wolfram" = "󰪚 $1";
          };
          "separate-outputs" = true;
        };

        "idle_inhibitor" = {
          format = "{icon}";
          "format-icons" = {
            activated = "";
            deactivated = "";
          };
        };

        tray = {
          spacing = 10;
        };

        clock = {
          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          format = "{:%T}";
          "format-alt" = "{:%F}";
          interval = 1;
        };

        cpu = {
          format = "{usage}% ";
          "format-alt" = "{avg_frequency}GHz";
        };

        memory = {
          format = "{}% 󰍛";
          "tooltip-format" = "{used} / {total}";
        };

        disk = {
          format = "{percentage_used}% 🖴";
          "tooltip-format" = "{used} / {total}";
        };

        temperature = {
          "hwmon-path" = "/sys/class/hwmon/hwmon4/temp1_input";
          "critical-threshold" = 80;
          format = "{temperatureC}°C {icon}";
          "format-icons" = [ "" "" "" ];
        };

        backlight = {
          format = "{percent}% {icon}";
          "format-icons" = [ "" "" "" "" "" "" "" "" "" ];
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          "format-full" = "{capacity}% {icon}";
          "format-charging" = "{capacity}% ";
          "format-plugged" = "{capacity}% ";
          "format-alt" = "{time} {icon}";
          "format-icons" = [ "" "" "" "" "" ];
        };

        "battery#bat2" = {
          bat = "BAT2";
        };

        "power-profiles-daemon" = {
          format = "{icon}";
          "tooltip-format" = "Power profile: {profile}\nDriver: {driver}";
          tooltip = true;
          "format-icons" = {
            default = "";
            performance = "";
            balanced = "";
            "power-saver" = "";
          };
        };

        network = {
          "format-wifi" = "{essid} ({signalStrength}%) ";
          "format-ethernet" = "{ipaddr}/{cidr} ";
          "tooltip-format" = "{ifname} via {gwaddr} ";
          "format-linked" = "{ifname} (No IP) ";
          "format-disconnected" = "Disconnected ⚠";
          "format-alt" = "{ifname}: {ipaddr}/{cidr}";
        };

        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          "format-bluetooth" = "{volume}% {icon} {format_source}";
          "format-bluetooth-muted" = " {icon} {format_source}";
          "format-muted" = " {format_source}";
          "format-source" = "{volume}% ";
          "format-source-muted" = "";
          "format-icons" = {
            headphone = "";
            "hands-free" = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          "on-click" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "on-click-right" = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };
      };
    };

    style = style;
  };
}