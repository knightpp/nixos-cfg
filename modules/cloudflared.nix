{
  config,
  lib,
  ...
}: let
  cfg = config.modules.cloudflared;
in {
  options.modules.cloudflared = {
    enable = lib.mkEnableOption "cloudflared";
  };

  config = lib.mkIf cfg.enable {
    services.cloudflared = {
      enable = true;
      tunnels = {
        potato = {
          credentialsFile = config.sops.secrets.cloudflared-potato-creds.path;
          default = "http_status:404";
        };
      };
    };

    sops.secrets = {
      cloudflared-potato-creds = {
        mode = "0400";
        owner = config.users.users.cloudflared.name;
      };
    };
  };
}
