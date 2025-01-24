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

    sops.secrets = let
      nginx = {
        mode = "0400";
        owner = config.users.users.nginx.name;
        sopsFile = ../secrets/nginx.yaml;
      };

      cloudflare = {
        mode = "0400";
        owner = config.users.users.cloudflared.name;
      };
    in
      lib.mkMerge [
        {
          cloudflared-potato-creds = lib.mkIf (cfg.tunnel == "potato") cloudflare;
          cloudflared-alta-creds = lib.mkIf (cfg.tunnel == "alta") cloudflare;
        }

        (lib.mkIf config.services.nginx.enable {
          "mastodon.knightpp.cc.pem" = nginx;
          "mastodon.knightpp.cc.key" = nginx;
          "cloudflare_origin_pull_ca.crt" = nginx;
        })
      ];
  };
}
