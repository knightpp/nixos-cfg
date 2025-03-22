{
  modulesPath,
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "uas"
    "sd_mod"
    "sdhci_pci"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/47ab68c7-9ac1-458b-badc-6e878475a8bd";
    fsType = "f2fs";
    options = [
      "noatime"
      "compress_algorithm=zstd"
      "compress_chksum"
      "atgc"
      "gc_merge"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C369-82DD";
    fsType = "vfat";
    options = [ "noatime" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/69c6f53c-7b80-4451-afe9-fbe63c9d4088"; }
  ];

  desktop-environment.gnome.enable = true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;
  services.xserver.xkbModel = "chromebook"; # TODO: Verify that it affects something

  boot.blacklistedKernelModules = [
    # Disable touch screen because sometimes it hangs and spams journald logs, which causes
    # high journald CPU usage. Usually happens after sleep.
    "raydium_i2c_ts"
  ];

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      dmidecode # bios script dependency
      ;
  };
}
