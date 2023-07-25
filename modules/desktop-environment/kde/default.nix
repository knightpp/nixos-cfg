{ config, pkgs, lib, ... }:

let
  cfg = config.desktop-environment.kde;
  inherit (lib) mkIf mkEnableOption;
in
{
  imports = [ ../apps ];

  options.desktop-environment.kde.enable = mkEnableOption "KDE";

  config = mkIf cfg.enable {
    desktop-environment.apps.enable = true;

    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    environment.plasma5.excludePackages = with pkgs.libsForQt5; [
      elisa
      print-manager
    ];

    systemd.user.services.add_ssh_keys = {
      script = ''
        ssh-add $HOME/.ssh/id_ed25519
      '';
      wantedBy = [ "default.target" ];
    };

    programs = {
      ssh.startAgent = true;
      ssh.askPassword = pkgs.lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass";
    };
  };
}
