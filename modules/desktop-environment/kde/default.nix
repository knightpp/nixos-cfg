{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.desktop-environment.kde;
  inherit (lib) mkIf mkEnableOption;
in {
  options.desktop-environment.kde.enable = mkEnableOption "KDE";

  config = mkIf cfg.enable {
    desktop-environment.enable = true;

    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;
    services.xserver.desktopManager.plasma5.useQtScaling = true;

    environment.plasma5.excludePackages = builtins.attrValues {
      inherit
        (pkgs.libsForQt5)
        elisa
        print-manager
        ;
    };

    environment = {
      sessionVariables = {
        # forces KDE to use wallet for ssh keys
        SSH_ASKPASS_REQUIRE = "prefer";
      };
    };

    systemd.user.services.add_ssh_keys = {
      script = ''
        ssh-add $HOME/.ssh/id_ed25519
      '';
      wantedBy = ["default.target"];
    };

    programs = {
      ssh.startAgent = true;
      ssh.askPassword = lib.mkForce "${pkgs.ksshaskpass.out}/bin/ksshaskpass";
    };
  };
}
