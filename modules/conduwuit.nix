{
  lib,
  config,
  ...
}: let
  cfg = config.modules.conduwuit;
in {
  options.modules.conduwuit = {
    enable = lib.mkEnableOption "conduwuit";
    unitConfig = lib.mkOption {
      description = "SystemD unit config";
      default = {};
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    services.conduwuit = {
      enable = true;
      settings = {
        global = {
          server_name = "knightpp.cc";
          address = ["127.0.0.1" "::1"];
          port = [6167];
          max_request_size = 100 * 1000 * 1000;

          new_user_displayname_suffix = "";
          allow_check_for_updates = false;
          # allow_legacy_media = false;

          forget_forced_upon_leave = true;
          lockdown_public_room_directory = true;

          log = "warn";
          log_colors = false;

          rocksdb_direct_io = false;
          ip_range_denylist = [
            "127.0.0.0/8"
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
            "100.64.0.0/10"
            "192.0.0.0/24"
            "169.254.0.0/16"
            "192.88.99.0/24"
            "198.18.0.0/15"
            "192.0.2.0/24"
            "198.51.100.0/24"
            "203.0.113.0/24"
            "224.0.0.0/4"
            "::1/128"
            "fe80::/10"
            "fc00::/7"
            "2001:db8::/32"
            "ff00::/8"
            "fec0::/10"
          ];

          url_preview_domain_contains_allowlist = [];
          url_preview_domain_explicit_allowlist = [];

          media_compat_file_link = false;
          presence_offline_timeout_s = 900;

          well_known = {
            server = "matrix.knightpp.cc:443";
            client = "https://matrix.knightpp.cc";
          };
        };
      };
    };

    systemd.services.conduwuit.unitConfig = cfg.unitConfig;
  };
}
