{inputs, ...}: {
  imports = with inputs.nixos-hardware.nixosModules; [
    common-cpu-intel
    common-gpu-intel
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usbhid" "usb_storage" "uas" "sd_mod" "rtsx_pci_sdmmc"];
  boot.initrd.kernelModules = ["dm-snapshot"];

  boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-partuuid/3dd7a06d-e146-4989-bc50-a9e17789304e";
      allowDiscards = true; # Used if primary device is a SSD
      preLVM = true;
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/34c6c316-152e-475d-baf7-8d0863e17cd5";
    fsType = "btrfs";
    options = ["subvol=@root,compress-force=zstd:4,discard=async"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/21C4-69AC";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/5f9e81d8-0e89-45b2-b468-5f850b18dd08";}
  ];

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
