{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.local-nas;
in
{
  options.modules.local-nas = {
    mount = lib.mkEnableOption "mount local nas";
  };

  config = lib.mkIf cfg.mount {
    services.rpcbind.enable = true; # needed for NFS

    systemd.mounts = [
      {
        type = "nfs";
        mountConfig = {
          Options = "noatime,nofail";
        };
        what = "alta.lan:/";
        where = "/nas/media";
      }
    ];

    systemd.automounts = [
      {
        wantedBy = [ "multi-user.target" ];
        automountConfig = {
          TimeoutIdleSec = "300";
        };
        where = "/nas/media";
      }
    ];
  };
}
