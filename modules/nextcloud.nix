{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.modules.nextcloud;
in
{
  options.modules.nextcloud = {
    enable = lib.mkEnableOption "nextcloud";

    trusted_domains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "potato.lan"
        "alta.lan"
      ];
      description = "domains allowed to access nextcloud";
    };

    preview = {
      heic = lib.mkEnableOption "heic" // {
        default = true;
      };
      video = lib.mkEnableOption "video";
    };

    openPort = lib.mkEnableOption "open port" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.nextcloud = {
      enable = true;
      hostName = "nextcloud.knightpp.cc";
      package = pkgs.nextcloud30;

      maxUploadSize = "100M";
      phpOptions = {
        memory_limit = lib.mkForce "512M";
      };

      settings = {
        trusted_domains = config.trusted_domains; # allows LAN access
        enabledPreviewProviders =
          [
            "OC\\Preview\\BMP"
            "OC\\Preview\\GIF"
            "OC\\Preview\\JPEG"
            "OC\\Preview\\Krita"
            "OC\\Preview\\MarkDown"
            "OC\\Preview\\MP3"
            "OC\\Preview\\OpenDocument"
            "OC\\Preview\\PNG"
            "OC\\Preview\\TXT"
            "OC\\Preview\\XBitmap"
          ]
          ++ lib.optionals config.preview.heic [
            "OC\\Preview\\HEIC"
          ]
          ++ lib.optionals config.preview.video [
            "OC\\Preview\\Movie"
          ];
      };

      config = {
        dbtype = "sqlite";
        dbpassFile = config.sops.secrets.nextcloudDBPass.path;
        adminpassFile = config.sops.secrets.nextcloudDBAdminPass.path;

        objectstore.s3 = {
          enable = true;
          bucket = "nextcloud";
          autocreate = false;
          key = "81f89e149bb085ffbff0f6ca3e38f8ef";
          secretFile = config.sops.secrets.nextcloudSecretAccessKey.path;
          region = "auto";
          hostname = "b6aeb9f8660a6c7ad4c310bc8b63ebb9.r2.cloudflarestorage.com";
        };
      };
    };

    sops.secrets =
      lib.genAttrs
        [
          "nextcloudSecretAccessKey"
          "nextcloudDBPass"
          "nextcloudDBAdminPass"
        ]
        (_: {
          mode = "0400";
          owner = config.users.users.nextcloud.name;
        });

    networking.firewall = lib.mkIf config.openPort {
      allowedTCPPorts = lib.mkIf cfg.openPort [ 80 ];
    };
  };
}
