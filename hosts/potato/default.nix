{
  lib,
  modulesPath,
  config,
  ...
}: {
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

  services.journald.extraConfig = ''
    Storage=volatile
    RuntimeMaxUse=64M
  '';

  networking.wireless.enable = false; # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  hardware.pulseaudio.enable = false;
  services.pipewire = {enable = false;};

  modules = {
    transmission = {
      enable = true;
      home = "/storage/porta/transmission";
      systemd.after = ["storage-porta-transmission.automount"];
      systemd.requires = ["storage-porta-transmission.automount"];
    };

    local-nas.mount = lib.mkForce false;
  };
}
