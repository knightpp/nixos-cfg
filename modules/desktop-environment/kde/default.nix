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
    assertions = [
      {
        assertion = !config.desktop-environment.gnome.enable;
        message = "KDE might conflict with Gnome";
      }
    ];

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
      systemPackages = builtins.attrValues {
        inherit (pkgs.libsForQt5) kmail elisa;
      };

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

    home-manager.sharedModules = [
      {
        xdg.configFile."plasma-localerc".text = ''
          [Formats]
          LANG=${cfg.formats}

          [Translations]
          LANGUAGE=${cfg.translations}
        '';
      }
    ];
  };
}
