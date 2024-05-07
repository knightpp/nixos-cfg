{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.desktop-environment.gnome;
in {
  options = {
    desktop-environment.gnome = {
      enable = lib.mkEnableOption "Gnome";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !config.desktop-environment.kde.enable;
        message = "KDE might conflict with Gnome";
      }
    ];

    desktop-environment.enable = true;

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome = {
      enable = true;
      extraGSettingsOverridePackages = [pkgs.gnome.mutter];
      extraGSettingsOverrides = ''
        [org.gnome.mutter]
        experimental-features=['scale-monitor-framebuffer']
      '';
    };

    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs.gnomeExtensions)
        appindicator
        night-theme-switcher
        vitals
        ;

      inherit
        (pkgs.gnome3)
        gnome-tweaks
        ;
    };
    services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];

    environment.gnome.excludePackages = with pkgs.gnome; [
      epiphany # web browser
      geary # email reader
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ];
  };
}
