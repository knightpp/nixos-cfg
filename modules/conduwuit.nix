{
  pkgs,
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
    services.matrix-conduit = {
      enable = true;
      package = pkgs.conduwuit;
      settings = {
        global = {
          server_name = "knightpp.cc";
          port = 6167;
          address = "::1";
          log = "warn";
          database_backend = "rocksdb";
          max_request_size = 100 * 1000 * 1000;
          zstd_compression = false;
          gzip_compression = false;
          brotli_compression = false;
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

          allow_guest_registration = false;
          log_guest_registrations = true;
          allow_guests_auto_join_rooms = false;
          allow_registration = false;

          # registration_token = false; # should be env secret CONDUWUIT_REGISTRATION_TOKEN

          allow_public_room_directory_over_federation = false;
          allow_public_room_directory_without_auth = false;
          lockdown_public_room_directory = true;
          allow_device_name_federation = false;
          url_preview_domain_contains_allowlist = [];
          url_preview_domain_explicit_allowlist = [];
          allow_profile_lookup_federation_requests = true;

          allow_check_for_updates = false;
          new_user_displayname_suffix = "";

          trusted_servers = ["matrix.org"];

          media_compat_file_link = false;

          allow_local_presence = true;

          allow_incoming_presence = true;

          allow_outgoing_presence = true;

          presence_offline_timeout_s = 900;

          allow_incoming_read_receipts = true;

          allow_outgoing_read_receipts = true;

          allow_outgoing_typing = true;

          allow_incoming_typing = true;

          well_known = {
            server = "matrix.knightpp.cc:443";
            client = "https://matrix.knightpp.cc";
          };
        };
      };
    };

    systemd.services.conduit.unitConfig = cfg.unitConfig;
  };
}
