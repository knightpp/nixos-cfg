{
  lib,
  modulesPath,
  config,
  pkgs,
  ...
}: let
  ffmpeg-full = pkgs.ffmpeg.override {ffmpegVariant = "full";};
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.initrd.availableKernelModules = [];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems = let
    mkPorta = opts: {
      device = "/dev/disk/by-uuid/431ca128-2dcf-40b3-9e99-eef11689a03d";
      fsType = "btrfs";
      label = "porta";
      options =
        [
          "nofail"
          "x-systemd.automount"
          "x-systemd.device-timeout=15s"
          "x-systemd.mount-timeout=15s"
          "ssd"
          "noatime"
          "commit=120"
        ]
        ++ opts;
    };
  in {
    "/" = {
      device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
      options = [
        "noatime"
        "commit=120"
      ];
    };

    "/storage/porta/main" = mkPorta ["subvol=@main"];
    "/storage/porta/transmission" = mkPorta ["subvol=@transmission"];
  };

  swapDevices = [
    {device = "/var/swapfile";}
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.end0.useDHCP = lib.mkDefault true;
  networking.hostName = "potato";
  time.timeZone = "Europe/Kyiv";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
  '';

  networking.wireless.enable = false; # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  hardware.pulseaudio.enable = false;
  services.pipewire = {enable = false;};

  users.users.potato = {
    isNormalUser = true;
    extraGroups = [];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG86t/Sa1mUjJtz7my7fhS0UvK3za5JCOyTw4u58rwvv Personal SSH"
    ];
  };

  home-manager.users.potato = {
    imports = [
      ../../hm
      {
        modules.home-manager.tools.enable = true;
        modules.home-manager.tools.interactive = false;
      }
    ];

    home.stateVersion = config.system.stateVersion;

    xdg.userDirs.createDirectories = false;
  };

  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.knightpp.cc";
    package = pkgs.nextcloud30;

    maxUploadSize = "100M";
    phpOptions = {
      memory_limit = lib.mkForce "512M";
    };

    settings = {
      trusted_domains = ["potato.lan"]; # allow LAN access
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
        ++ [
          "OC\\Preview\\HEIC"
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
  sops.secrets = let
    nextcloud =
      lib.genAttrs [
        "nextcloudSecretAccessKey"
        "nextcloudDBPass"
        "nextcloudDBAdminPass"
      ] (_: {
        mode = "0400";
        owner = config.users.users.nextcloud.name;
      });
    cloudflare = {
      cloudflared-potato-creds = {
        mode = "0400";
        owner = config.users.users.cloudflared.name;
      };
    };
  in
    lib.mkMerge [
      nextcloud
      cloudflare
    ];
  networking.firewall = {
    allowedTCPPorts = [80];
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      potato = {
        credentialsFile = config.sops.secrets.cloudflared-potato-creds.path;
        default = "http_status:404";
      };
    };
  };

  services = {
    flood = {
      enable = true;
      openFirewall = true;
      host = "0.0.0.0";
      extraArgs = [
        "--truser=transmission"
        "--trpass=transmission"
        "--trurl=http://127.0.0.1:9091/transmission/rpc"
        "--allowedpath=/storage/porta/transmission"
      ];
    };

    transmission = let
      home = "/storage/porta/transmission";
    in {
      enable = true;
      settings = {
        download-dir = "${home}/downloads";
        incomplete-dir = "${home}/incomplete";
        incomplete-dir-enabled = false;
        encryption = 2; # require
        message-level = 3; # warn
        peer-limit-global = 5000;
        peer-limit-per-torrent = 500;
        peer-port = 51413;
        rpc-port = 9091;
        trash-original-torrent-files = true;
        rpc-username = "transmission";
        rpc-password = "transmission";
      };

      openPeerPorts = true;
      performanceNetParameters = true;

      home = home;

      package = pkgs.transmission_4;
    };
  };
  systemd.services.transmission = {
    after = ["storage-porta-transmission.automount"];
    requires = ["storage-porta-transmission.automount"];
  };

  environment.systemPackages = builtins.attrValues {
    inherit ffmpeg-full;
  };

  system.stateVersion = "24.11";
}
