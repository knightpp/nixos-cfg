{
  config,
  lib,
  ...
}: let
  cfg = config.modules.mastodon;
  localDomain = "mastodon.knightpp.cc";
in {
  options.modules.mastodon = {
    enable = lib.mkEnableOption "mastodon";
    unitConfig = lib.mkOption {
      description = "SystemD unit config";
      default = {};
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    services.mastodon = let
      secrets = lib.attrsets.genAttrs [
        "vapidPublicKeyFile"
        "vapidPrivateKeyFile"
        "activeRecordEncryptionDeterministicKeyFile"
        "activeRecordEncryptionKeyDerivationSaltFile"
        "activeRecordEncryptionPrimaryKeyFile"
        "secretKeyBaseFile"
        "otpSecretFile"
      ] (attr: config.sops.secrets."${lib.strings.removeSuffix "File" attr}".path);
    in
      {
        enable = true;
        configureNginx = true;
        inherit localDomain;

        webPort = 55001;
        sidekiqPort = 55002;

        streamingProcesses = 1;
        webProcesses = 0; # this enable single-mode, instead of cluster
        webThreads = 4;
        sidekiqThreads = 8;

        database = {
          createLocally = true;
        };

        smtp = {
          createLocally = false;

          user = "postmaster@mg.knightpp.cc";
          host = "smtp.eu.mailgun.org";
          port = 587;
          fromAddress = "Mastodon <notifications@mastodon.knightpp.cc>";
          authenticate = true;
          passwordFile = config.sops.secrets.smtpPassword.path;
        };

        extraConfig = {
          SMTP_AUTH_METHOD = "plain";
          SMTP_OPENSSL_VERIFY_MODE = "none";
          SMTP_ENABLE_STARTTLS = "auto";
          RAILS_LOG_LEVEL = "warn";
          LOG_LEVEL = "warn";
        };
      }
      // secrets;

    sops.secrets = let
      allow = {
        mode = "0400";
        owner = config.users.users."${config.services.mastodon.user}".name;
        sopsFile = ../secrets/mastodon.yaml;
      };
    in
      lib.attrsets.genAttrs [
        "activeRecordEncryptionPrimaryKey"
        "activeRecordEncryptionKeyDerivationSalt"
        "activeRecordEncryptionDeterministicKey"
        "secretKeyBase"
        "otpSecret"
        "vapidPublicKey"
        "vapidPrivateKey"
        "smtpPassword"
      ] (_: allow);

    services.nginx.virtualHosts."${localDomain}" = {
      enableACME = false;
      forceSSL = true;

      sslCertificate = config.sops.secrets."mastodon.knightpp.cc.pem".path;
      sslCertificateKey = config.sops.secrets."mastodon.knightpp.cc.key".path;

      extraConfig = ''
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
        ssl_client_certificate ${config.sops.secrets."cloudflare_origin_pull_ca.crt".path};
        client_max_body_size 100m;
      '';
    };

    systemd.targets.mastodon.unitConfig = cfg.unitConfig;

    # disable redis persistence, but this disables saving home feed
    # services.redis.servers.mastodon.save = [];

    services.postgresql.authentication = let
      db = config.services.mastodon.database;
    in ''
      local ${db.name} ${db.user} trust
    '';
  };
}
