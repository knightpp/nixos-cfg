{
  config,
  lib,
  ...
}: let
  cfg = config.modules.users;
in {
  options = {
    modules.users.knightpp.enable = lib.mkEnableOption "knightpp";
  };

  config = lib.mkIf cfg.knightpp.enable {
    users.users = {
      knightpp = {
        isNormalUser = true;
        group = "knightpp";
        extraGroups = [
          "nixoscfg"
          "networkmanager"
          "systemd-journal"
          "docker"
          "plugdev" # probably for qmk keyboards
          "dialout" # for serial ports (esp32)
          "adbusers" # see https://nixos.wiki/wiki/Android
          config.users.groups.keys.name # sops
        ];
        initialHashedPassword = "$6$pgzhN8I3kJ1O35mZ$dzoVn596Htt3Jc7S1ftGyRnoxHmqvNpY.ZKtN3c/j5y0K3ZlbpwbaMaA6Mw5XnuVQxrDQ0184dkMtZp98thXU1";
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG86t/Sa1mUjJtz7my7fhS0UvK3za5JCOyTw4u58rwvv Personal SSH"
        ];
      };
    };
    users.groups = {
      knightpp = {};
    };
    nix.settings.trusted-users = ["knightpp"];

    home-manager.users.knightpp = {
      imports = [
        ../hm
        {
          modules.home-manager.tools.enable = true;
          modules.home-manager.tools.interactive = lib.mkDefault true;
        }
      ];

      home.stateVersion = config.system.stateVersion;

      xdg.userDirs = {
        enable = true;
        createDirectories = true;
      };
    };
  };
}
