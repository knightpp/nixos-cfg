{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.desktop-environment.kde;
  inherit (lib) mkIf mkEnableOption;
in {
  options.desktop-environment.kde = {
    enable = mkEnableOption "KDE";

    user = lib.mkOption {
      type = lib.types.str;
      description = "User name. Some settings should be set for user, not system";
    };

    formats = lib.mkOption {
      type = lib.types.str;
      default = "uk_UA.UTF-8";
      description = "Sets formats (date, time, etc.) for KDE";
    };

    translations = lib.mkOption {
      type = lib.types.str;
      default = "uk_UA:en_GB:en_US";
      description = "Sets translations for KDE";
    };
  };

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

      xdg.configFile."plasma-localerc".text = ''
        [Formats]
        LANG=${cfg.formats}

        [Translations]
        LANGUAGE=${cfg.translations}
      '';
    };
  };
}
