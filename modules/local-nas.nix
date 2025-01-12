{
  config,
  lib,
  ...
}: let
  cfg = config.modules.local-nas;
in {
  options.modules.local-nas = {
    mount = lib.mkEnableOption "mount local nas";
  };

  config = lib.mkIf cfg.mount {
    services.rpcbind.enable = true; # needed for NFS

    systemd.mounts = [
      {
        type = "nfs";
        mountConfig = {
          Options = "noatime,nofail,noauto";
        };
        what = "alta.lan:/media";
        where = "/mnt/media";
      }
    ];

    systemd.automounts = [
      {
        wantedBy = ["multi-user.target"];
        automountConfig = {
          TimeoutIdleSec = "300";
        };
        where = "/mnt/media";
      }
    ];
  };
}
