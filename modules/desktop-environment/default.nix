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

        alacritty = {
          enable = true;
          settings = {
            import = ["${pkgs.alacritty-theme}/gruvbox_dark.yaml"];
            live_config_reload = false;
            window.resize_increments = false;
            font = {
              size = 14;
            };
            selection.save_to_clipboard = true;
            key_bindings = let
              mode = mode: entries: map (x: x // {mode = mode;}) entries;
            in
              mode "Vi|~Search" [
                {
                  action = "Up";
                  key = "E";
                }
                {
                  action = "Down";
                  key = "N";
                }
                {
                  action = "Left";
                  key = "M";
                }
                {
                  action = "Right";
                  key = "I";
                }

                {
                  action = "WordLeft";
                  key = "B";
                }
                {
                  action = "WordRight";
                  key = "W";
                }
                {
                  action = "WordLeftEnd";
                  key = "B";
                  mods = "Shift";
                }
                {
                  action = "WordRightEnd";
                  key = "W";
                  mods = "Shift";
                }

                {
                  action = "Bracket";
                  key = "Key5";
                  mods = "Shift";
                }

                {
                  action = "ToggleNormalSelection";
                  key = "V";
                }
                {
                  action = "ToggleLineSelection";
                  key = "V";
                  mods = "Shift";
                }
                {
                  action = "ToggleBlockSelection";
                  key = "V";
                  mods = "Control";
                }

                {
                  action = "SearchNext";
                  key = "J";
                }
                {
                  action = "SearchPrevious";
                  key = "K";
                }

                {
                  action = "Open";
                  key = "O";
                }

                {
                  action = "ToggleViMode";
                  key = "H";
                }
                {
                  action = "ScrollToBottom";
                  key = "H";
                }
              ];
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
        (pkgs)
        appimage-run
        vscode
        obsidian
        telegram-desktop
        firefox
        discord
        calibre
        handbrake
        xclip
        easyeffects
        workrave
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
      packages = builtins.attrValues {
        inherit
          (pkgs)
          noto-fonts
          noto-fonts-emoji
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          dejavu_fonts
          monaspace
          ;
        nerdfonts = pkgs.nerdfonts.override {fonts = ["FiraCode"];};
      };

      enableDefaultPackages = false; # Fixes wrong braille symbols for graph in the bottom app
      fontconfig.allowBitmaps = false;
    };
  };
}
