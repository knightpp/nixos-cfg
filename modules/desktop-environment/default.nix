{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.desktop-environment;
in {
  imports = [./kde];

  options.desktop-environment.enable = lib.mkEnableOption "Desktop Environment";

  config = lib.mkIf cfg.enable {
    networking.useDHCP = false;
    networking.networkmanager.enable = true;

    xdg.portal.xdgOpenUsePortal = true;

    environment.systemPackages = builtins.attrValues {
      inherit (config.pkgs.unstable) vscode;
      # inherit (pkgs)
      #   firefox
      #   ;
      # telegram-desktop
    };

    services.flatpak.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    fonts = {
      fonts = builtins.attrValues {
        inherit
          (pkgs)
          noto-fonts
          noto-fonts-emoji
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          ;

        nerdfonts = pkgs.nerdfonts.override {fonts = ["FiraCode"];};
      };

      fontconfig.allowBitmaps = false;
    };
  };
}
