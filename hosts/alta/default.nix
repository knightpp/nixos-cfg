{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

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
        where = "/storage/porta/transmission";
        what = device;
        options = "nofail,ssd,noatime,commit=120,subvol=@transmission";
        type = "btrfs";
        before = ["transmission.service"];
      }
      {
        where = "/var/lib/private/flood";
        what = device;
        options = "nofail,ssd,noatime,commit=120,subvol=@flood";
        type = "btrfs";
        before = ["flood.service"];
      }
      {
        where = "/var/lib/docker";
        what = device;
        options = "nofail,ssd,noatime,commit=120,subvol=@docker";
        type = "btrfs";
        before = ["docker.service"];
      }
      {
        where = "/swap";
        what = device;
        options = "nofail,ssd,noatime,commit=120,subvol=@swap";
        type = "btrfs";
      }
      {
        where = "/storage/ssd/mastodon";
        what = "/dev/disk/by-uuid/cbd8666a-11b5-4fc0-928f-be955eaacb4e";
        type = "btrfs";
        options = "nofail,ssd,noatime,commit=120,subvol=@mastodon";
        before = ["docker.service"];
      }
      {
        where = "/storage/ssd/matrix";
        what = "/dev/disk/by-uuid/cbd8666a-11b5-4fc0-928f-be955eaacb4e";
        type = "btrfs";
        options = "nofail,ssd,noatime,commit=120,subvol=@matrix";
        before = ["docker.service"];
      }
      {
        where = "/storage/ssd/readeck";
        what = "/dev/disk/by-uuid/cbd8666a-11b5-4fc0-928f-be955eaacb4e";
        type = "btrfs";
        options = "nofail,ssd,noatime,commit=120,subvol=@readeck";
        before = ["docker.service"];
      }
    ];
    automounts = let
      mkAutoMount = where: {
        where = where;
        # automountConfig = {
        #   ExtraOptions = "noatime,commit=120,ssd";
        # };
        wantedBy = ["multi-user.target"];
      };
    in
      map mkAutoMount [
        "/storage/porta/transmission"
        "/var/lib/private/flood"
        "/var/lib/docker"
        "/swap"
        "/storage/ssd/mastodon"
        "/storage/ssd/matrix"
        "/storage/ssd/readeck"
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

  networking.useDHCP = lib.mkDefault true;
  networking.hostName = "alta"; # TODO: move into module
  time.timeZone = "Europe/Kyiv";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
  '';

  networking.wireless.enable = false;
  hardware.pulseaudio.enable = false;
  services.pipewire.enable = false;

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };

  modules = {
    users.knightpp.enable = true;

    transmission = {
      enable = true;
      home = "/storage/porta/transmission";
      systemd.after = ["storage-porta-transmission.automount"];
      systemd.requires = ["storage-porta-transmission.automount"];
    };

    local-nas.mount = lib.mkForce false;
  };
}
