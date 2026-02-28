{ config, pkgs, ... }:

{
  programs.git.settings.user = {
    name = "Your Name";
    email = "your.email@example.com";
  };

  programs.ssh = {
    enableDefaultConfig = false;
  };

  home.sessionVariables = {
    SERVICE = "ZHIPU";
    MODEL_NAME = "glm-4.7-flash";
    AUDIO_FILE = "${config.home.homeDirectory}/gnosia.ogg";
  };

  programs.waybar.settings.bottom = {
    position = "bottom";
    height = 20;
    spacing = 10;
    "modules-left" = [
      "custom/count_words"
    ];
    "modules-right" = [ "custom/solar_status" ];

    "custom/solar_status" = {
      format = "{}";
      exec = "cat .solar_status";
      signal = 2;
    };

    "custom/count_words" = {
      format = "🗣️: {}";
      exec = "sqlite3 .log.db \"SELECT SUM(length(content)) FROM speech WHERE date(time_start) = date('now', 'localtime');\"";
      interval = 1;
      "on-click" = "speech.sh simple";
      "on-click-right" = "voice_commands.sh";
    };
  };
}
