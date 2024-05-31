{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.fcitx5;
in {
  options = {
    modules.fcitx5 = {
      enable = lib.mkEnableOption "Fcitx5";
    };
  };

  config = lib.mkIf cfg.enable {
    i18n.inputMethod.enabled = "fcitx5";
    i18n.inputMethod.fcitx5.addons = builtins.attrValues {inherit (pkgs) fcitx5-mozc;};
    environment.sessionVariables = {
      XMODIFIERS = "@im=fcitx";
      QT_IM_MODULE = "fcitx";
      GTK_IM_MODULE = "fcitx";
    };

    environment.systemPackages =
      if config.modules.desktop-environment.gnome.enable
      then [pkgs.gnomeExtensions.kimpanel]
      else [];
  };
}
