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

    environment.systemPackages = let
      superslicer = let
        version = "2.5.59.5";
      in
        pkgs.appimageTools.wrapType2 {
          name = "superslicer";
          src = pkgs.fetchurl {
            url = "https://github.com/supermerill/SuperSlicer/releases/download/${version}/SuperSlicer-ubuntu_18.04-${version}.AppImage";
            hash = "sha256-ykeMUEMGKeNZN7QAWagJQzZumSOXvYNyCSt36vzYPIo=";
          };
        };

      superslicerFixed = pkgs.writeScriptBin "superslicer" ''
        #! ${pkgs.bash}/bin/bash
        # AppImage version of Cura loses current working directory and treats all paths relateive to $HOME.
        # So we convert each of the files passed as argument to an absolute path.
        # This fixes use cases like `cd /path/to/my/files; cura mymodel.stl anothermodel.stl`.
        # args=()
        # for a in "$@"; do
        #   if [ -e "$a" ]; then
        #     a="$(realpath "$a")"
        #   fi
        #   args+=("$a")
        # done
        # exec "${superslicer}/bin/superslicer" "''${args[@]}"

        export LANGUAGE="en_US"
        export LOCALE="en_US.UTF-8"
        export LANG=""
        exec "${superslicer}/bin/superslicer" "$@"
      '';
      superslicerDesktopItem = pkgs.makeDesktopItem {
        name = "SuperSlicer";
        desktopName = "SuperSlicer";
        exec = "${superslicerFixed}/bin/superslicer";
        terminal = false;
      };
    in
      builtins.attrValues {
        superslicer = superslicerFixed;
        inherit superslicerDesktopItem;

        inherit (pkgs.libsForQt5) elisa; # music player
        inherit
          (pkgs)
          appimage-run
          prusa-slicer
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
