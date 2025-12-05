{ config, pkgs, ... }:

{
  home.username = "paradoxist";
  home.homeDirectory = "/home/paradoxist";
  home.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
  ];

  programs.git = {
    enable = true;
    settings.user.name = "ProfXv";
    settings.user.email = "849460963@qq.com";
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
      if [ $TERM = xterm-kitty ]; then
        source /home/paradoxist/.config/home-manager/modules/local/chat/chat.zsh
      fi
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
