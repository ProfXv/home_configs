{ config, pkgs, ... }:

let
  private = builtins.fromJSON (builtins.readFile ./private.json);
  positiveUser = private.username;
in
{
  boot.kernelParams = [ "iwlwifi.11n_disable=1" ];
  networking.hostName = "paradoxer";

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-rime
        qt6Packages.fcitx5-chinese-addons
      ];
      settings = {
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "pinyin";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "pinyin";
          "Groups/0/Items/2".Name = "shuangpin";
          GroupOrder."0" = "Default";
        };
        addons = {
          pinyin.globalSection = {
            PageSize = 10;
          };
          shuangpin.globalSection = {
            PageSize = 10;
          };
        };
      };
    };
  };
}
