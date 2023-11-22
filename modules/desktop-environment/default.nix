{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.desktop-environment;
in {
  imports = [./kde ./gnome];

  options.desktop-environment = {
    enable = lib.mkEnableOption "Desktop Environment";
    user = lib.mkOption {
      type = lib.types.str;
      description = "User name. Some settings should be set for user, not system";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users."${cfg.user}" = {
      programs = {
        mpv = {
          enable = true;
          config = {
            ao = "pipewire";
            vo = "gpu";
            profile = "gpu-hq";
            hwdec = "auto";

            msg-color = "yes"; # color log messages on terminal
            cache = "yes"; # uses a large seekable RAM cache even for local input.
            # cache-secs=300 # uses extra large RAM cache (needs cache=yes to make it useful).
            demuxer-max-back-bytes = "20M"; # sets fast seeking
            demuxer-max-bytes = "80M"; # sets fast seeking
          };
        };
      };
    };

    networking.useDHCP = false;
    networking.networkmanager.enable = true;

    xdg.portal.xdgOpenUsePortal = true;

    programs.dconf.enable = true; # Needed for easyeffects

    environment.systemPackages = builtins.attrValues {
      inherit (pkgs.libsForQt5) elisa; # music player
      inherit
        (config.pkgs.unstable)
        vscode
        obsidian
        telegram-desktop
        ;
      inherit
        (pkgs)
        firefox
        discord
        calibre
        handbrake
        xclip
        easyeffects
        ;
    };

    sound.enable = true; # enables alsamixer settings to be persisted across reboots
    hardware.pulseaudio.enable = false;
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
