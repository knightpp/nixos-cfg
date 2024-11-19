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
      extraGSettingsOverridePackages = [pkgs.mutter];
      # enable fractional scaling in gnome
      extraGSettingsOverrides = ''
        [org.gnome.mutter]
        experimental-features=['scale-monitor-framebuffer']
      '';
    };

    # disable sleep at all to fix going to sleep when sshed
    services.xserver.displayManager.gdm.autoSuspend = false;
    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;

    # hint electron apps to use wayland:
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        papers
        polari
        gnome-tweaks
        ;

      inherit
        (pkgs.gnomeExtensions)
        appindicator
        night-theme-switcher
        vitals
        ;
    };
    services.udev.packages = with pkgs; [gnome-settings-daemon];

    environment.gnome.excludePackages = with pkgs; [
      epiphany # web browser
      geary # email reader
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      evince # document viewer replaced by papers
    ];
  };
}
