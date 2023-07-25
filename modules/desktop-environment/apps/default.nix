{ config, pkgs, lib, ... }:

let
  cfg = config.desktop-environment.apps;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.desktop-environment.apps.enable = mkEnableOption "Apps";

  config = mkIf cfg.enable {
    environment.systemPackages = builtins.attrValues {
      inherit (pkgs)
        mpv
        ;
      vscode = config.nixpkgs.unstable.vscode;
    };

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
