{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-partlabel/lvm";

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
      fcitx5-chinese-addons
    ];
  };

  

  users.users.paradoxist = {
    isNormalUser = true;
    group = "paradoxist";
    extraGroups = [ "wheel" "input" "uinput" "video" "docker"];
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
    wofi firefox-devedition mpv dunst
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
    mathematica
    gnumake gcc
    (python3.withPackages (ps: with ps; [
      astral dateutils bleak binance-connector selenium pip
    ]))
    nodejs
    gemini-cli
    vial qq wechat
    (pass.withExtensions (ext: [ ext.pass-otp ]))
  ];

  environment.sessionVariables = {
      LIBVA_DRIVERS_PATH = "${pkgs.intel-media-driver}/lib/dri";
  };

  fonts.packages = with pkgs;[
    noto-fonts-cjk-sans noto-fonts-emoji dejavu_fonts nerd-fonts.noto font-awesome
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

  system.stateVersion = "25.05";
}
