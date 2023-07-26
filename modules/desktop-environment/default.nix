{ config, lib, ... }:
let
  cfg = config.desktop-environment;
in
{
  imports = [ ./kde ];

  options.desktop-environment.enable = lib.mkEnableOption "Desktop Environment";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      config.pkgs.unstable.vscode
      # pkgs.telegram-desktop
    ];

    services.flatpak.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
