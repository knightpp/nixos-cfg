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

    programs.dconf.enable = true; # Needed for easyeffects

    environment.systemPackages = builtins.attrValues {
      inherit (pkgs.libsForQt5) elisa; # music player
      inherit (config.pkgs.unstable) vscode;
      inherit
        (pkgs)
        firefox
        handbrake
        obsidian
        prismlauncher
        xclip
        easyeffects
        ;
      # telegram-desktop
    };

    services.flatpak.enable = true;

    sound.enable = true; # enables alsamixer settings to be persisted across reboots
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
          dejavu_fonts
          ;

        nerdfonts = pkgs.nerdfonts.override {fonts = ["FiraCode"];};
      };

      enableDefaultFonts = false; # Fixes wrong braille symbols for graph in the bottom app
      fontconfig.allowBitmaps = false;
    };
  };
}
