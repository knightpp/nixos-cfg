{
  lib,
  modulesPath,
  config,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/44444444-4444-4444-8888-888888888888";
      fsType = "ext4";
      options = [
        "noatime"
        "commit=120"
      ];
    };
  };

  systemd = {
    mounts = let
      device = "/dev/disk/by-uuid/431ca128-2dcf-40b3-9e99-eef11689a03d";
    in [
      {
        where = "/var/lib/transmission";
        what = device;
        options = "nofail,ssd,noatime,commit=120,subvol=@transmission";
        type = "btrfs";
      }
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
      {
        where = "/var/lib/private/flood";
        what = device;
        options = "nofail,ssd,noatime,commit=120,subvol=@flood";
        type = "btrfs";
      }
      {
        where = "/swap";
        what = device;
        options = "nofail,ssd,noatime,commit=120,subvol=@swap";
        type = "btrfs";
      }
      {
        where = "/var/lib/mastodon";
        what = "/dev/disk/by-uuid/cbd8666a-11b5-4fc0-928f-be955eaacb4e";
        type = "btrfs";
        options = "nofail,ssd,noatime,commit=120,subvol=@mastodon";
      }
      {
        where = "/var/lib/postgresql";
        what = "/dev/disk/by-uuid/cbd8666a-11b5-4fc0-928f-be955eaacb4e";
        type = "btrfs";
        options = "nofail,ssd,noatime,commit=120,subvol=@postgresql";
      }
      {
        where = "/var/lib/private/matrix-conduit";
        what = "/dev/disk/by-uuid/cbd8666a-11b5-4fc0-928f-be955eaacb4e";
        type = "btrfs";
        options = "nofail,ssd,noatime,commit=120,subvol=@matrix";
      }
      {
        where = "/var/lib/private/readeck";
        what = "/dev/disk/by-uuid/cbd8666a-11b5-4fc0-928f-be955eaacb4e";
        type = "btrfs";
        options = "nofail,ssd,noatime,commit=120,subvol=@readeck";
      }
    ];

    automounts = let
      mkAutoMount = where: {
        where = where;
        wantedBy = ["multi-user.target"];
      };
    in
      map mkAutoMount [
        "/export/downloads"
        "/export/watcher"
        "/swap"
        "/var/lib/private/readeck"
        "/var/lib/private/matrix-conduit"
        "/var/lib/postgresql"
        "/var/lib/mastodon"
        "/var/lib/private/flood"
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
  systemd.services.flood.unitConfig = {
    RequiresMountsFor = "/var/lib/private/flood";
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
    exports = let
      commonOpts = [
        "insecure"
        "rw"
        "async"
        "all_squash" # use anon uid,gid for any operation
      ];
      rootOpts = lib.strings.concatStringsSep "," ([
          "crossmnt"
          "fsid=root"
          "anonuid=${toString config.users.users.nfsclient.uid}"
          "anongid=${toString config.users.groups.nfsclient.gid}"
        ]
        ++ commonOpts);
      downloadsOpts = lib.strings.concatStringsSep "," ([
          "mp=/var/lib/transmission"
          "anonuid=${toString config.users.users.transmission.uid}"
          "anongid=${toString config.users.groups.transmission.gid}"
        ]
        ++ commonOpts);
    in ''
      /export 192.168.0.0/24(${rootOpts}) fdee:2dcd:73e8::1/60(${rootOpts})
      /export/downloads 192.168.0.0/24(${downloadsOpts}) fdee:2dcd:73e8::1/60(${downloadsOpts})
    '';
  };
  networking.firewall.allowedTCPPorts = [2049]; # nfs v4 uses only 2049
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
      unitConfig.RequiresMountsFor = "/var/lib/private/matrix-conduit";
    };

    mastodon = {
      enable = true;
      unitConfig.RequiresMountsFor = "/var/lib/mastodon";
    };

    local-nas.mount = lib.mkForce false;
  };

  # takes up RAM and doesn't do much on SBCs
  services.fwupd.enable = false;
}
