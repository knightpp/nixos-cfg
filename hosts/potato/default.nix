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

  modules = {
    transmission = {
      enable = true;
      home = "/storage/porta/transmission";
      systemd.after = ["storage-porta-transmission.automount"];
      systemd.requires = ["storage-porta-transmission.automount"];
    };

    local-nas.mount = lib.mkForce false;
  };

  system.stateVersion = "24.11";
}
