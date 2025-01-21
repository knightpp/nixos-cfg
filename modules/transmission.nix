{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.modules.transmission;
in {
  options.modules.transmission = {
    enable = lib.mkEnableOption "transmission";

    withFlood = lib.mkEnableOption "flood" // {default = true;};

    home = lib.mkOption {
      example = "/storage/porta/transmission";
      description = "path to downloads/state data";
      type = lib.types.path;
    };

    unitConfig = lib.mkOption {
      description = "SystemD unit config";
      default = {};
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      flood = {
        enable = cfg.withFlood;
        openFirewall = true;
        host = "0.0.0.0";
        extraArgs = [
          "--truser=transmission"
          "--trpass=transmission"
          "--trurl=http://127.0.0.1:9091/transmission/rpc"
          "--allowedpath=${cfg.home}"
        ];
      };

      transmission = {
        enable = true;
        settings = {
          # since I set download-dir and incomplete-dir
          # the script won't create these folders.
          # also it needs $home/.config/transmission-daemon folder
          download-dir = "${cfg.home}/downloads";
          incomplete-dir = "${cfg.home}/incomplete";
          incomplete-dir-enabled = false;
          encryption = 2; # require
          message-level = 3; # warn
          peer-limit-global = 5000;
          peer-limit-per-torrent = 500;
          peer-port = 51413;
          rpc-port = 9091;
          trash-original-torrent-files = true;
          rpc-username = "transmission";
          rpc-password = "transmission";
        };

        openPeerPorts = true;
        performanceNetParameters = true;

        home = cfg.home;

        package = pkgs.transmission_4;
      };
    };

    systemd.services.transmission = {
      unitConfig = cfg.unitConfig;
      serviceConfig = {
        RestartSec = "15";
        RestartMaxDelaySec = "120";
        Restart = "on-failure";
      };
    };
  };
}
