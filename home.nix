{ config, pkgs, ... }:

{
  home.username = "paradoxist";
  home.homeDirectory = "/home/paradoxist";
  home.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
  ];

  programs.git = {
    enable = true;
    userName = "ProfXv";
    userEmail = "849460963@qq.com";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      grep = "grep --color=auto";
      vim = "nvim";
      vi = "vim";
    };
    loginExtra = ''
      if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
        Hyprland
      fi
    '';
    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      source /home/paradoxist/.config/home-manager/modules/local/chat/chat.zsh
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
  };

  systemd.user = {
    timers = {
      reset-speak-count = {
        Timer = {
          OnCalendar = "daily";
          AccuracySec = "1us";
        };
        Install.WantedBy = [ "timers.target" ];
      };
      clear-gemini-usage = {
        Timer.OnCalendar = "16:00:00";
        Install.WantedBy = [ "timers.target" ];
      };
    };
    services = {
      reset-speak-count.Service.ExecStart = "/bin/sh -c 'echo 0 > ~/.daily/speak_count'";
      clear-gemini-usage.Service.ExecStart = "/bin/sh -c 'echo > ~/.gemini_usage.tsv'";
    };
  };

  home.file.".config/hypr".source = ./modules/programs/hypr;
  home.file.".config/waybar".source = ./modules/programs/waybar;
  home.file.".config/kitty".source = ./modules/programs/kitty;
  home.file.".config/wofi".source = ./modules/programs/wofi;
  home.file.".config/yazi".source = ./modules/programs/yazi;
  home.file.".config/nvim".source = ./modules/programs/nvim;
  home.file.".config/btop".source = ./modules/programs/btop;
  home.file.".config/mihomo".source = ./modules/programs/mihomo;
  home.file.".ssh/config".source = ./modules/services/ssh/config;
  home.file.".local/bin" = {
    source = ./modules/local/bin;
    recursive = true;
    executable = true;
  };
}
