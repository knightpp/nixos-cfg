{
  lib,
  modulesPath,
  config,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/3cf23025-8ad7-4b2c-8466-3bd44108e03b";
    fsType = "btrfs";
    options = [ "subvol=@root,compress=zstd:1,noatime,commit=120" ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/3cf23025-8ad7-4b2c-8466-3bd44108e03b";
    fsType = "btrfs";
    options = [ "subvol=@home,compress=zstd:1,noatime,commit=120" ];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/7920-5DF0";
    fsType = "vfat";
  };

  systemd = {
    mounts =
      let
        oldSsd = "/dev/disk/by-uuid/cbd8666a-11b5-4fc0-928f-be955eaacb4e";
        datatraveler = "/dev/disk/by-uuid/317f3945-1d41-4857-8d7f-b9f49d93c088";
        mkBtrfsMount = device: subvol: where: {
          where = where;
          what = device;
          options = "nofail,ssd,noatime,commit=120,subvol=${subvol}";
          type = "btrfs";
        };
      in
      [
        {
          where = "/export/downloads";
          what = "/var/lib/transmission/downloads";
          options = "bind";
        }
        {
          where = "/export/watcher";
          what = "/var/lib/transmission/watcher";
          options = "bind";
        }
        (mkBtrfsMount datatraveler "@swap" "/swap")
        (mkBtrfsMount datatraveler "@transmission" "/var/lib/transmission")
        (mkBtrfsMount oldSsd "@mastodon" "/var/lib/mastodon")
        (mkBtrfsMount oldSsd "@redis-mastodon" "/var/lib/redis-mastodon")
        (mkBtrfsMount oldSsd "@postgresql" "/var/lib/postgresql")
        (mkBtrfsMount oldSsd "@matrix" "/var/lib/private/conduwuit")
        (mkBtrfsMount oldSsd "@readeck" "/var/lib/private/readeck")
      ];

    automounts =
      let
        mkAutoMount = where: {
          where = where;
          wantedBy = [ "multi-user.target" ];
        };
      in
      map mkAutoMount [
        "/export/downloads"
        "/export/watcher"
        "/swap"
        "/var/lib/private/readeck"
        "/var/lib/private/conduwuit"
        "/var/lib/redis-mastodon"
        "/var/lib/postgresql"
        "/var/lib/mastodon"
        "/var/lib/transmission"
      ];
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      options = [
        "nofail"
      ];
    }
  ];

  systemd.services.transmission.unitConfig = {
    RequiresMountsFor = "/var/lib/transmission";
  };

  services.nfs.settings = {
    nfsd = {
      port = 2049;
      UDP = "no";
      TCP = "yes";
      vers3 = "no";
    };
  };
  services.nfs.server = {
    enable = true;
    createMountPoints = true;
    exports =
      let
        commonOpts = [
          "insecure"
          "rw"
          "async"
          "all_squash" # use anon uid,gid for any operation
        ];
        rootOpts = lib.strings.concatStringsSep "," (
          [
            "crossmnt"
            "fsid=root"
            "anonuid=${toString config.users.users.nfsclient.uid}"
            "anongid=${toString config.users.groups.nfsclient.gid}"
          ]
          ++ commonOpts
        );
        downloadsOpts = lib.strings.concatStringsSep "," (
          [
            "mp=/var/lib/transmission"
            "anonuid=${toString config.users.users.transmission.uid}"
            "anongid=${toString config.users.groups.transmission.gid}"
          ]
          ++ commonOpts
        );
      in
      ''
        /export 192.168.0.0/24(${rootOpts}) fdee:2dcd:73e8::1/60(${rootOpts})
        /export/downloads 192.168.0.0/24(${downloadsOpts}) fdee:2dcd:73e8::1/60(${downloadsOpts})
      '';
  };
  networking.firewall.allowedTCPPorts = [ 2049 ]; # nfs v4 uses only 2049
  users.users.nfsclient = {
    uid = 114; # picked here https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/misc/ids.nix
    isSystemUser = true;
    group = "nfsclient";
  };
  users.groups.nfsclient = {
    gid = 114;
  };

  modules = {
    cloudflared = {
      enable = true;
      tunnel = "alta";
    };

    transmission = {
      enable = true;
      home = "/var/lib/transmission";
      unitConfig.RequiresMountsFor = "/var/lib/transmission";
    };

    readeck = {
      enable = true;
      unitConfig.RequiresMountsFor = "/var/lib/private/readeck";
    };

    conduwuit = {
      enable = true;
      unitConfig.RequiresMountsFor = "/var/lib/private/conduwuit";
    };

    mastodon = {
      enable = true;
      unitConfig.RequiresMountsFor = "/var/lib/mastodon";
    };

    local-nas.mount = lib.mkForce false;
  };

  systemd.services.redis-mastodon.unitConfig = {
    RequiresMountsFor = "/var/lib/redis-mastodon";
  };

  # takes up RAM and doesn't do much on SBCs
  services.fwupd.enable = false;
}
