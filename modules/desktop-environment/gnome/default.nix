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

    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    environment.systemPackages = with pkgs; [gnomeExtensions.appindicator];
    services.udev.packages = with pkgs; [gnome.gnome-settings-daemon];

    environment.gnome.excludePackages =
      (with pkgs; [
        gnome-tour
      ])
      ++ (with pkgs.gnome; [
        epiphany # web browser
        geary # email reader
        totem # video player
        tali # poker game
        iagno # go game
        hitori # sudoku game
        atomix # puzzle game
      ]);
  };
}
