{
  modulesPath,
  lib,
  config,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = ["xhci_pci" "uas" "sd_mod" "sdhci_pci"];
  boot.kernelModules = ["kvm-intel"];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/32eebb90-869f-436b-acbe-86cbed1d6cfb";
    fsType = "f2fs";
    options = [
      "noatime"
      "compress_algorithm=zstd:6"
      "compress_chksum"
      "atgc"
      "gc_merge"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/5672-4E76";
    fsType = "vfat";
    options = ["noatime"];
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/81e64caa-fee9-4ba1-91d1-d1823a7ed60a";}
  ];

  nix = {
    settings = {
      extra-substituters = [
        "ssh://nix-ssh@nixbox.lan"
      ];
    };
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  networking.hostName = "chlap";
  time.timeZone = "Europe/Kyiv";
  i18n.defaultLocale = "uk_UA.UTF-8";

  desktop-environment.user = "knightpp";
  desktop-environment.gnome.enable = true;
  repl.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
  services.xserver.xkbModel = "chromebook"; # TODO: Verify that it affects something

  environment.systemPackages = [
    # TODO: installing old telegram because I do not want flatpak here
    pkgs.telegram-desktop
    pkgs.discord
  ];

  services.journald.extraConfig = ''
    Storage=volatile
  '';

  boot.blacklistedKernelModules = [
    # Disable touch screen because sometimes it hangs and spams journald logs, which causes
    # high journald CPU usage. Usually happens after sleep.
    "raydium_i2c_ts"
  ];
}
