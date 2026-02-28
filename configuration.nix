{ config, pkgs, ... }:

let
  privateConfigPath = if builtins.pathExists ./private/private.json
                      then ./private/private.json
                      else ./templates/private/private.json;
  privateConfig = builtins.fromJSON (builtins.readFile privateConfigPath);
  usernames = privateConfig.username;
  reverseString = str: pkgs.lib.concatStrings (pkgs.lib.reverseList (pkgs.lib.stringToCharacters str));

  userPairs = map (user: {
    positive = user;
    negative = reverseString user;
  }) usernames;

  positiveUser = (builtins.head userPairs).positive;
  negativeUser = (builtins.head userPairs).negative;

  systemPrivatePath = if builtins.pathExists ./private/system-private.nix
                      then ./private/system-private.nix
                      else ./templates/private/system-private.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    systemPrivatePath
  ];

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "vkms" ];
    enableContainers = true;
    loader = if builtins.pathExists /sys/firmware/efi then {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    } else {
      grub.enable = true;
      grub.device = builtins.readFile ./private/disk.txt;
    };
    initrd.luks.devices."cryptroot" = {
      device = "/dev/disk/by-partlabel/charge";
      keyFile = "/dev/disk/by-partlabel/primer";
      keyFileSize = 4096;
      fallbackToPassword = true;
    };
  };

  systemd.services = pkgs.lib.listToAttrs (map (tty:
    let
      user = if pkgs.lib.mod tty 2 == 1 then positiveUser else negativeUser;
      agetty = "${pkgs.util-linux}/sbin/agetty";
      login = "${pkgs.shadow}/bin/login";
    in {
      name = "getty@tty${toString tty}";
      value = {
        overrideStrategy = "asDropin";
        serviceConfig.ExecStart = [
          ""
          "@${agetty} agetty --login-program ${login} --autologin ${user} --noclear %I $TERM"
        ];
      };
    }
  ) [ 1 2 3 4 5 6 ]);

  networking = {
    wireless.iwd.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 445 139 ];
      allowedUDPPorts = [ 137 138 ];
    };
  };

  services.tailscale.enable = true;
  services.mihomo = {
    enable = true;
    configFile = "/etc/mihomo/config.yaml";
    webui = pkgs.metacubexd;
    extraOpts = "-d /etc/mihomo";
  };
  services.samba = {
    enable = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "netbios name" = config.networking.hostName;
        "map to guest" = "bad user";
        "guest account" = positiveUser;
        "server min protocol" = "NT1";
      };
      Public = {
        path = "${config.users.users.${positiveUser}.home}/Public";
        "read only" = false;
        "public" = true;
      };
    };
  };
  services.sunshine.enable = true;
  services.jupyter = {
    enable = true;
    ip = "127.0.0.1";
    port = 8642;
    user = "jupyter";
    notebookDir = "/var/lib/jupyter";
    command = "jupyter notebook";
    password = "";
    notebookConfig = ''
      c.ServerApp.token = ""
      c.ServerApp.password = ""
      c.ServerApp.disable_check_xsrf = True
    '';
  };




  users.users = pkgs.lib.mkMerge (map (pair: {
    ${pair.positive} = {
      isNormalUser = true;
      group = pair.positive;
      extraGroups = [ "wheel" "input" "uinput" "video" "docker" "disk" "dialout" "tty" pair.negative ];
      shell = pkgs.zsh;
      homeMode = "750";
    };
    ${pair.negative} = {
      isNormalUser = true;
      group = pair.negative;
      extraGroups = [ "wheel" "input" "uinput" "video" "docker" "disk" "dialout" "tty" pair.positive ];
      shell = pkgs.zsh;
      homeMode = "750";
    };
  }) userPairs);

  users.groups = pkgs.lib.mkMerge ([
    (pkgs.lib.mkMerge (map (pair: {
      ${pair.positive} = {};
      ${pair.negative} = {};
    }) userPairs))
    { uinput = {}; }
  ]);

  nixpkgs.config.allowUnfree = true;
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  programs.hyprland.enable = true;
  programs.zsh.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
  };

  virtualisation.docker.enable = true;
  virtualisation.waydroid.enable = true;

  environment.systemPackages = with pkgs; [
    home-manager
    qt5.qtwayland qt6.qtwayland
    gst_all_1.gst-plugins-good gst_all_1.gst-plugins-bad gst_all_1.gst-plugins-ugly
    wofi firefox-devedition mpv libnotify dunst
    wl-clipboard cliphist ydotool wtype wev grim slurp wf-recorder socat
    waybar hyprpaper hyprlock hypridle
    inotify-tools smartmontools
    rsync p7zip unzip
    jq
    eza bat tree pstree tldr
    scrcpy wayvnc freerdp sunshine wine winetricks
    kitty neovim yazi btop
    ffmpeg imagemagick
    nyxt texliveBasic
    steam
    cmatrix lolcat neofetch
    wvkbd woomer
    feishu wemeet qqmusic
    android-tools
    github-cli mihomo
    docker-compose
    # mathematica
    gnumake gcc
    uv
    (python3.withPackages (ps: with ps; [
      astral geopy timezonefinder dateutils bleak binance-connector selenium beautifulsoup4 euporie pip
    ]))
    nodejs
    sqlite
    bubblewrap
    codex gemini-cli qwen-code
    vial qq
    # vial qq wechat
    (pass.withExtensions (ext: [ ext.pass-otp ]))
    hyprpolkitagent
  ];

  systemd.tmpfiles.rules = [
    "d /run/polkit-1/rules.d 0755 root root -"
    "d /usr/local/share/polkit-1/rules.d 0755 root root -"
  ];

  fonts.packages = with pkgs;[
    noto-fonts-cjk-sans-static noto-fonts-color-emoji dejavu_fonts nerd-fonts.noto font-awesome
  ];

  hardware.bluetooth.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
      AllowUsers = [ positiveUser negativeUser ];
      LogLevel = "VERBOSE";
    };
  };
  services.fail2ban = {
    enable = true;
    bantime = "1s";
    maxretry = 1;
    bantime-increment.enable = true;
  };
  services.vnstat.enable = true;
  services.atd.enable = true;
  services.minidlna.enable = true;
  services.power-profiles-daemon.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };
  services.gvfs.enable = true;

  services.logind.settings.Login.HandlePowerKey = "hibernate";

  system.stateVersion = "25.11";
}
