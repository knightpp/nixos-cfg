{
  modulesPath,
  pkgs,
  inputs,
  ...
}: let
  ffmpeg-full = pkgs.ffmpeg.override {ffmpegVariant = "full";};
in {
  imports = with inputs.nixos-hardware.nixosModules; [
    (modulesPath + "/installer/scan/not-detected.nix")

    common-cpu-amd
    common-cpu-amd-pstate
    common-gpu-amd
    common-hidpi
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usbhid"];
  boot.kernelPackages = pkgs.linuxPackages_latest; # Kernel 6.9.2 fixed poweroff

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/ff53c09a-c690-4548-a2ae-f9c292c6c69e";
    fsType = "btrfs";
    options = ["subvol=@root,compress-force=zstd:4,noatime,commit=120"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/ff53c09a-c690-4548-a2ae-f9c292c6c69e";
    fsType = "btrfs";
    options = ["subvol=@home,compress-force=zstd:4,noatime,commit=120"];
  };

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/490B-481B";
    fsType = "vfat";
  };

  networking.hostName = "nixbox";
  time.timeZone = "Europe/Kyiv";

  desktop-environment.user = "knightpp";
  desktop-environment.gnome.enable = true;

  environment.systemPackages = builtins.attrValues {
    inherit ffmpeg-full;
  };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.bluetooth.enable = true;

  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
    enableOnBoot = false;
  };

  programs.steam = {
    enable = true;

    package = pkgs.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          gamescope
          mangohud
        ];
    };
  };

  repl.enable = true;
}
