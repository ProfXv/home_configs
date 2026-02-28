{ config, pkgs, ... }:

let
  privatePath = if builtins.pathExists ./private/private.json
                then ./private/private.json
                else ./templates/private/private.json;
  private = builtins.fromJSON (builtins.readFile privatePath);
  fontSize = 12 * private.screen.width / 1920;

  userPrivatePath = if builtins.pathExists ./private/user-private.nix
                    then ./private/user-private.nix
                    else ./templates/private/user-private.nix;
  baseImports = [ userPrivatePath ];
  hyprImports = [
    ./modules/hyprland.nix
    ./modules/hyprlock.nix
    ./modules/hyprpaper.nix
    ./modules/hypridle.nix
  ];
  waybarImports = [ ./modules/waybar.nix ];
in
{
  nixpkgs.config.allowUnfree = true;

  home = {
    username = builtins.head private.username;
    homeDirectory = "/home/${builtins.head private.username}";
    stateVersion = "25.11";

    packages = with pkgs; [
      sops
      age
      claude-code-router
      alacritty-theme
    ];

    sessionVariables = {
      XCURSOR_SIZE = "24";
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS = "@im=fcitx";
      NIX_PATH = "home-manager=${pkgs.home-manager.src}:$NIX_PATH";
      SDL_RENDER_DRIVER = "opengles2";
      JUPYTER_SERVER_URL = "http://127.0.0.1:8642";
    };
  };

  programs.git.enable = true;
  programs.ssh.enable = true;

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
      PATH=$HOME/.local/bin:$PATH
      eval $(load-secrets.sh)
      if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && tty >/dev/null; then
        case $(tty) in
          /dev/tty6) exec journalctl -f ;;
          /dev/tty*) 
            for desktop in ${pkgs.lib.concatStringsSep " " private.desktops}; do
              pgrep -u $USER -f "$desktop" >/dev/null || exec "$desktop"
            done
            exec tmux
            ;;
        esac
      fi
    '';
    initContent = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      # if [ $TERM = xterm-kitty ]; then
      source ~/.config/home-manager/modules/local/chat/chat.zsh
      # fi
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      ''--bind "enter:accept-or-print-query"''
      "--layout=reverse"
      "--cycle"
    ];
  };

  programs.direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
      config.whitelist.prefix = [ "/home/tsixodarap/Desktop/Projects" ];
      stdlib = ''
        use_conjure() {
          use flake
          PATH_add "."
          [ -f Cargo.toml ] && watch_file Cargo.toml
          [ -f package.json ] && watch_file package.json
          [ -f pyproject.toml ] && watch_file pyproject.toml
        }
      '';
  };

  programs.kitty = {
    enable = true;
    themeFile = "Box";
    shellIntegration.mode = null;
    settings = {
      font_size = fontSize;
      background_opacity = "0.5";
      cursor_trail = 1;
      allow_remote_control = true;
    };
    keybindings = {
      "ctrl+c" = "copy_or_interrupt";
      "ctrl+v" = "paste_from_clipboard";
      "ctrl+up" = "change_font_size all +1.0";
      "ctrl+down" = "change_font_size all -1.0";
      "ctrl+shift+enter" = "launch --cwd=current";
      "ctrl+shift+t" = "launch --cwd=current --type=tab";
    };
  };

  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty-graphics;
    settings = {
      window.opacity = 0.5;
      font.size = fontSize;
      general.import = [
        "theme.toml"
      ];
      keyboard.bindings = [
        {
          key = "Up";
          mods = "Control";
          action = "IncreaseFontSize";
        }
        {
          key = "Down";
          mods = "Control";
          action = "DecreaseFontSize";
        }
      ];
    };
  };

  programs.wofi = {
    enable = true;
    settings = {
      show = "drun,run";
      width = "50%";
      height = "50%";
      always_parse_args = true;
      show_all = false;
      insensitive = true;
      allow_images = true;
      normal_window = true;
      allow_markup = true;
    };
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    plugins = with pkgs.yaziPlugins; {
      inherit piper mediainfo bookmarks git full-border smart-enter chmod sudo compress wl-clipboard yatline lazygit projects relative-motions diff rsync recycle-bin mount;
    };
    initLua = ''
      require("git"):setup()
      require("full-border"):setup {
        type = ui.Border.ROUNDED,
      }
      require("smart-enter"):setup {
        open_multi = true,
      }
      require("yatline"):setup()
      require("projects"):setup({})
    '';
    keymap = {
      mgr.prepend_keymap = [
        { on = [ "\"" ]; run = "plugin bookmarks save"; desc = "Save bookmark"; }
        { on = [ "'" ]; run = "plugin bookmarks jump"; desc = "Jump to bookmark"; }
        { on = [ "b" "d" ]; run = "plugin bookmarks delete"; desc = "Delete bookmark"; }
        { on = [ "b" "D" ]; run = "plugin bookmarks delete_all"; desc = "Delete all bookmarks"; }
        { on = [ "c" "m" ]; run = "plugin chmod"; desc = "Chmod selected files"; }
        { on = [ "c" "z" ]; run = "plugin compress"; desc = "Compress selected files"; }
        { on = [ "s" "p" ]; run = "plugin sudo -- paste"; desc = "Sudo paste"; }
        { on = [ "s" "d" ]; run = "plugin sudo -- remove"; desc = "Sudo remove"; }
        { on = [ "c" "i" ]; run = [ ''shell --confirm -- for path in %s; do echo "file://$path"; done | wl-copy -t text/uri-list'' ]; desc = "Copy to system clipboard"; }
        { on = [ "<F9>" ]; run = "plugin mediainfo -- toggle-metadata"; desc = "Toggle media metadata"; }
        { on = [ "g" "l" ]; run = "plugin lazygit"; desc = "Open lazygit"; }
        { on = [ "e" "s" ]; run = "plugin projects save"; desc = "Save project"; }
        { on = [ "e" "l" ]; run = "plugin projects load"; desc = "Load project"; }
        { on = [ "e" "d" ]; run = "plugin projects delete"; desc = "Delete project"; }
        { on = [ "e" "f" ]; run = "plugin diff"; desc = "Diff files"; }
        { on = [ "e" "r" ]; run = "plugin rsync"; desc = "Rsync"; }
        { on = [ "e" "t" ]; run = "plugin recycle-bin -- trash"; desc = "Move to recycle bin"; }
        { on = [ "e" "m" ]; run = "plugin mount"; desc = "Mount/unmount"; }
      ];
    };
    settings = {
      plugin = {
        prepend_fetchers = [
          { id = "git"; url = "*"; run = "git"; }
          { id = "git"; url = "*/"; run = "git"; }
        ];
        prepend_preloaders = [
          { mime = "{audio,video,image}/*"; run = "mediainfo"; }
          { mime = "application/subrip"; run = "mediainfo"; }
          { mime = "application/postscript"; run = "mediainfo"; }
        ];
        prepend_previewers = [
          { url = "*.md"; run = ''piper -- CLICOLOR_FORCE=1 glow -w $w -s dark "$1"''; }
          { url = "*.ipynb"; run = ''piper -- euporie-preview --color-depth 24 --syntax-highlighting "$1" 2>/dev/null''; }
          { mime = "{audio,video,image}/*"; run = "mediainfo"; }
          { mime = "application/subrip"; run = "mediainfo"; }
          { mime = "application/postscript"; run = "mediainfo"; }
        ];
      };
      opener = {
        wolfram = [
          { run = ''wolframnb "$@"''; desc = "Wolfram Open"; }
        ];
        euporie = [
          { run = ''euporie-notebook "$@"''; block = true; desc = "Euporie Open"; }
        ];
        sops = [
          { run = ''sops edit "$@"''; block = true; desc = "SOPS Edit"; }
        ];
      };
      open = {
        prepend_rules = [
          { url = "*.nb"; use = "wolfram"; }
          { url = "*.wl"; use = "wolfram"; }
          { url = "*.m"; use = "wolfram"; }
          { url = "*.ipynb"; use = "euporie"; }
          { url = "*.enc.yaml"; use = "sops"; }
        ];
      };
    };
  };

  programs.btop = {
    enable = true;
    settings = {
      theme_background = false;
    };
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    historyLimit = 50000;
    keyMode = "vi";
    prefix = "M-a";
    terminal = "tmux-256color";
    disableConfirmationPrompt = true;

    extraConfig = ''
      set -g default-shell ${pkgs.zsh}/bin/zsh

      # 真彩色支持
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
      set-environment -g COLORTERM "truecolor"

      # 状态栏配置（类似 Hyprland waybar）
      set -g status on
      set -g status-position top
      set -g status-style bg=default,fg=white
      set -g status-left-length 40
      set -g status-right-length 80
      set -g status-left "#[fg=green,bold]#S #[fg=white]| "
      set -g status-right "#[fg=cyan]%Y-%m-%d #[fg=white]| #[fg=yellow]%H:%M"
      set -g window-status-format "#[fg=white]#I:#W"
      set -g window-status-current-format "#[fg=cyan,bold]#I:#W"

      # 面板边框
      set -g pane-border-style fg=brightblack
      set -g pane-active-border-style fg=cyan

      # 消息样式
      set -g message-style bg=default,fg=yellow
      set -g message-command-style bg=default,fg=yellow

      # ===== 键绑定（类似 Hyprland）=====
      # 注：tmux 无法使用 Super 键，使用 Alt 代替

      # Alt + 方向键：移动焦点（类似 SUPER + 方向键）
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D
      bind -n M-h select-pane -L
      bind -n M-l select-pane -R
      bind -n M-k select-pane -U
      bind -n M-j select-pane -D

      # Alt + Shift + 方向键：移动面板（类似 SUPER + SHIFT + 方向键）
      bind -n M-S-Left swap-pane -s '{left-of}'
      bind -n M-S-Right swap-pane -s '{right-of}'
      bind -n M-S-Up swap-pane -s '{up-of}'
      bind -n M-S-Down swap-pane -s '{down-of}'
      bind -n M-H swap-pane -s '{left-of}'
      bind -n M-L swap-pane -s '{right-of}'
      bind -n M-K swap-pane -s '{up-of}'
      bind -n M-J swap-pane -s '{down-of}'

      # Alt + Ctrl + 方向键：调整面板大小（类似 SUPER + CTRL + 方向键）
      bind -n M-C-Left resize-pane -L 2
      bind -n M-C-Right resize-pane -R 2
      bind -n M-C-Up resize-pane -U 2
      bind -n M-C-Down resize-pane -D 2
      bind -n M-C-h resize-pane -L 2
      bind -n M-C-l resize-pane -R 2
      bind -n M-C-k resize-pane -U 2
      bind -n M-C-j resize-pane -D 2

      # Alt + [/]：切换窗口（类似 SUPER + Page Up/Down）
      bind -n M-[ previous-window
      bind -n M-] next-window
      bind -n M-PageUp previous-window
      bind -n M-PageDown next-window

      # Alt + Shift + [/]：移动窗口顺序
      bind -n M-S-PageUp swap-window -t -1\; select-window -t -1
      bind -n M-S-PageDown swap-window -t +1\; select-window -t +1

      # Alt + Enter：新建面板（类似 SUPER 打开终端）
      bind -n M-Enter split-window -h -c "#{pane_current_path}"
      bind -n M-S-Enter split-window -v -c "#{pane_current_path}"

      # Alt + t：新建窗口
      bind -n M-t new-window -c "#{pane_current_path}"

      # Alt + 数字：切换到对应窗口（类似 SUPER + 数字切换工作区）
      bind -n M-1 select-window -t 1
      bind -n M-2 select-window -t 2
      bind -n M-3 select-window -t 3
      bind -n M-4 select-window -t 4
      bind -n M-5 select-window -t 5
      bind -n M-6 select-window -t 6
      bind -n M-7 select-window -t 7
      bind -n M-8 select-window -t 8
      bind -n M-9 select-window -t 9

      # Alt + x：关闭面板（类似 SUPER + Delete）
      bind -n M-x kill-pane

      # Alt + f：全屏切换
      bind -n M-f resize-pane -Z

      # Alt + z：切换面板布局
      bind -n M-z next-layout

      # Alt + r：重命名窗口（类似 Hyprland 的重命名工作区）
      bind -n M-r command-prompt -I "#W" "rename-window '%%'"

      # Alt + d：分离会话
      bind -n M-d detach-client

      # Alt + s：选择会话
      bind -n M-s choose-tree -Zs

      # Alt + w：选择窗口
      bind -n M-w choose-tree -Zw

      # 复制模式使用 vi 键绑定
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
    '';
  };

  programs.zellij = {
    enable = false;
    enableZshIntegration = true;
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/markdown" = "nvim.desktop";
      "x-scheme-handler/http" = "google-chrome-new-window.desktop";
      "x-scheme-handler/https" = "google-chrome-new-window.desktop";
      "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
      "x-scheme-handler/tonsite" = "org.telegram.desktop.desktop";
      "x-scheme-handler/clash" = "clash-verge.desktop";
      "x-scheme-handler/clash-verge" = "clash-verge.desktop";
    };
  };

  xdg.desktopEntries.google-chrome-new-window = {
    name = "Google Chrome (New Window)";
    exec = "google-chrome-stable --new-window %U";
    icon = "google-chrome";
    categories = [ "Network" "WebBrowser" ];
  };

  xdg.desktopEntries.nvim = {
    name = "Neovim";
    exec = "alacritty -e nvim %F";
    icon = "nvim";
    categories = [ "Utility" "TextEditor" ];
    mimeType = [ "text/markdown" "text/plain" ];
  };


  home.file = {
    ".config/nvim" = {
      source = ./modules/programs/nvim;
      recursive = true;
    };
    ".local/bin" = {
      source = ./modules/local/bin;
      recursive = true;
      executable = true;
    };
    ".local/bin/select_theme.sh" = {
      executable = true;
      text = ''
        #!/bin/sh

        type=$(printf "wallpaper\nlockscreen\ntheme" | fzf --header="Select type")
        [ -z "$type" ] && exit 0

        case "$type" in
          wallpaper)
            dir=~/Downloads/wallpapers
            target=~/.wallpaper
            post_cmd="pkill -USR2 swaybg"
            ;;
          lockscreen)
            dir=~/Downloads/wallpapers
            target=~/.lockscreen
            post_cmd="timeout 1 swaybg -i ~/.lockscreen &"
            ;;
          theme)
            dir="${pkgs.alacritty-theme}/share/alacritty-theme"
            target=~/.config/alacritty/theme.toml
            post_cmd=""
            ;;
        esac

        while true; do
          list=$(ls $dir)
          pos=$(echo "$list" | grep -Fnx "$selected" | cut -d: -f1)
          selected=$(echo "$list" | fzf --bind "load:pos($pos)")
          [ -z "$selected" ] && break
          ln -sf "$dir/$selected" "$target" && eval "$post_cmd"
        done
      '';
    };
  };

  services.wayvnc = {
    enable = true;
    autoStart = true;
    systemdTarget = "graphical-session.target";
    settings = {
      address = "0.0.0.0";
      port = 5900;
    };
  };

  systemd.user.services.wstpserver = {
    Unit = {
      Description = "Wolfram WSTP Server";
      After = [ "network.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.mathematica}/libexec/Mathematica/SystemFiles/Links/WSTPServer/wstpserver";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.wallpaper = {
    Unit = {
      Description = "Wallpaper";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i %h/.wallpaper";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ./private/secrets.enc.yaml;
    secrets = {
      GITHUB_TOKEN = {};
    };
  };

  imports = baseImports ++ hyprImports ++ waybarImports ++ [
    <sops-nix/modules/home-manager/sops.nix>
  ];
}
