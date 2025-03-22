{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.transmission;
in
{
  options.modules.transmission = {
    enable = lib.mkEnableOption "transmission";

    withFlood = lib.mkEnableOption "flood";

    home = lib.mkOption {
      example = "/storage/porta/transmission";
      description = "path to downloads/state data";
      type = lib.types.path;
    };

    unitConfig = lib.mkOption {
      description = "SystemD unit config";
      default = { };
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
          watch-dir = "${cfg.home}/watcher";
          incomplete-dir-enabled = false;
          watch-dir-enabled = true;

          encryption = 2; # require
          message-level = 3; # warn
          peer-limit-global = 5000;
          peer-limit-per-torrent = 500;
          peer-port = 51413;
          rpc-port = 9091;
          rpc-bind-address = "0.0.0.0";
          rpc-whitelist = "192.168.1.*";
          rpc-whitelist-enable = true;
          rpc-host-whitelist-enabled = true;
          rpc-host-whitelist = "alta.lan";
          rpc-authentication-required = false;
          trash-original-torrent-files = true;
          rpc-username = "transmission";
          rpc-password = "transmission";
        };
        # this wont't work because it runs too early in boot process, it accepts "deps" though
        # downloadDirPermissions = "777"; # allow other write acces to allow NFS access

        openPeerPorts = true;
        openRPCPort = true;
        performanceNetParameters = true;

        home = cfg.home;

        package = pkgs.transmission_4;
      };
    };

    systemd.services.transmission = {
      unitConfig = cfg.unitConfig;
      serviceConfig = {
        RestartSec = "15";
        RestartSteps = 5;
        RestartMaxDelaySec = "120";
        Restart = "on-failure";
      };
    };
  };
}
