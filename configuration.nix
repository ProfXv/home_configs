{ config, pkgs, ... }:

let
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
    kernelParams = [ "iwlwifi.11n_disable=1" "btintel.enable_llp=0" "btintel.enable_sleep=0" ];
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

  services.getty.autologinUser = "paradoxist";

  networking.hostName = "paradoxer";
  networking.wireless.iwd.enable = true;
  networking.firewall.enable = true;
  services.tailscale.enable = true;

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-chinese-addons
    ];
  };

  

  users.users.paradoxist = {
    isNormalUser = true;
    group = "paradoxist";
    extraGroups = [ "wheel" "input" "uinput" "video" "docker" "disk" "dialout" "tty" ];
    shell = pkgs.zsh;
    initialPassword = "password";
  };

  users.groups.paradoxist = {};
  users.groups.uinput = {};

  nixpkgs.config = {
    allowUnfree = true;
    android_sdk.accept_license = true;
    packageOverrides = pkgs: {
      unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
        config = config.nixpkgs.config;
      };
    };
  };
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.substituters = [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
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

  environment.sessionVariables = {
      LIBVA_DRIVERS_PATH = "${pkgs.intel-media-driver}/lib/dri";
      PATH = "${pkgs.hyprpolkitagent}/libexec";
  };

  systemd.tmpfiles.rules = [
    "d /run/polkit-1/rules.d 0755 root root -"
    "d /usr/local/share/polkit-1/rules.d 0755 root root -"
  ];

  fonts.packages = with pkgs;[
    noto-fonts-cjk-sans noto-fonts-color-emoji dejavu_fonts nerd-fonts.noto font-awesome
  ];

  hardware.bluetooth.enable = true;
  services.openssh.enable = true;
  services.vnstat.enable = true;
  services.atd.enable = true;
  services.minidlna.enable = true;
  services.power-profiles-daemon.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig.pipewire = {
      "context.modules" = [
        {
          name = "libpipewire-module-echo-cancel";
          args = {
            "source_master" = "bluez_input.41:42:78:94:36:02";
            "sink_master" = "alsa_output.pci-0000_00_1f.3.hdmi-stereo";
            "aec_method" = "webrtc";
          };
        }
      ];
    };
  };
  services.gvfs.enable = true;

  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    # AR Glasses (Google Nexus/Pixel Device)
    ACTION=="add", ATTRS{idVendor}=="18d1", ATTRS{idProduct}=="4ee2", RUN+="${pkgs.coreutils}/bin/echo 1 > /home/paradoxist/.phone_state"
    ACTION=="remove", ATTRS{idVendor}=="18d1", ATTRS{idProduct}=="4ee2", RUN+="${pkgs.coreutils}/bin/echo 0 > /home/paradoxist/.phone_state"
    # HONOR Phone (ALI-AN00)
    ACTION=="add", ATTRS{idVendor}=="339b", ATTRS{idProduct}=="107d", RUN+="${pkgs.coreutils}/bin/echo 1 > /home/paradoxist/.phone_state"
    ACTION=="remove", ATTRS{idVendor}=="339b", ATTRS{idProduct}=="107d", RUN+="${pkgs.coreutils}/bin/echo 0 > /home/paradoxist/.phone_state"
  '';

  system.stateVersion = "25.11";
}
