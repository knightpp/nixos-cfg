{
  inputs,
  pkgs,
  ...
}: {
  imports = with inputs.nixos-hardware.nixosModules; [
    common-cpu-intel
    common-gpu-intel
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usbhid" "usb_storage" "uas" "sd_mod" "rtsx_pci_sdmmc"];
  boot.initrd.kernelModules = ["dm-snapshot"];

  boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-partuuid/df652d07-8e6e-49c3-956c-627b22081c82";
      allowDiscards = true; # Used if primary device is a SSD
      preLVM = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/379dba30-67ad-45ef-9736-345c498a5e16";
    fsType = "btrfs";
    options = ["subvol=@root,compress-force=zstd:4,discard=async,noatime"];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-partuuid/0d863ef0-7710-416c-9844-6a4fa9639f73";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/22d6f7dc-dac6-4a3a-a466-ce8d8c6bd779";}
  ];

  networking.hostName = "porta";
  time.timeZone = "Europe/Kyiv";

  hardware.cpu.intel.updateMicrocode = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.bluetooth.enable = true;

  desktop-environment.user = "knightpp";
  desktop-environment.gnome.enable = true;

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    enableOnBoot = false;
  };

  services.flatpak.enable = true;
  workarounds.flatpak.enable = true;

  repl.enable = true;
}
