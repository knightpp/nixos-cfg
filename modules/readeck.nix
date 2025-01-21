{
  config,
  lib,
  ...
}: let
  cfg = config.modules.readeck;
in {
  options.modules.readeck = {
    enable = lib.mkEnableOption "readeck";
    unitConfig = lib.mkOption {
      description = "SystemD unit config";
      default = {};
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    services.readeck = {
      enable = true;
      environmentFile = config.sops.secrets.readeckEnv.path;
      settings = {
        main.log_level = "warn";
      };
    };

    systemd.services.readeck.unitConfig = cfg.unitConfig;

    sops.secrets.readeckEnv = {
      mode = "0400";
      owner = config.users.users.root.name;
    };
  };
}
