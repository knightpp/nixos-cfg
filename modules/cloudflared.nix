{
  config,
  lib,
  ...
}: let
  cfg = config.modules.cloudflared;
in {
  options.modules.cloudflared = {
    enable = lib.mkEnableOption "cloudflared";
    tunnel = lib.mkOption {
      type = lib.types.enum ["potato" "alta"];
    };
  };

  config = lib.mkIf cfg.enable {
    services.cloudflared = {
      enable = true;
      tunnels = {
        potato = lib.mkIf (cfg.tunnel == "potato") {
          credentialsFile = config.sops.secrets.cloudflared-potato-creds.path;
          default = "http_status:404";
        };

        alta = lib.mkIf (cfg.tunnel == "alta") {
          credentialsFile = config.sops.secrets.cloudflared-alta-creds.path;
          default = "http_status:404";
        };
      };
    };

    sops.secrets = {
      cloudflared-potato-creds = lib.mkIf (cfg.tunnel == "potato") {
        mode = "0400";
        owner = config.users.users.cloudflared.name;
      };

      cloudflared-alta-creds = lib.mkIf (cfg.tunnel == "alta") {
        mode = "0400";
        owner = config.users.users.cloudflared.name;
      };
    };
  };
}
