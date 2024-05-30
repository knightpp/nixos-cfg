{
  pkgs,
  inputs,
  ...
}: let
  ffmpeg-full = pkgs.ffmpeg.override {ffmpegVariant = "full";};
in {
  imports = with inputs.nixos-hardware.nixosModules; [
    common-cpu-amd
    common-cpu-amd-pstate
    common-hidpi
  ];

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

  # enables to write Japanese
  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = builtins.attrValues {inherit (pkgs) fcitx5-mozc;};
  environment.sessionVariables = {
    XMODIFIERS = "@im=fcitx";
    QT_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";
  };

  environment.systemPackages = builtins.attrValues {
    inherit ffmpeg-full;

    inherit (pkgs.gnomeExtensions) kimpanel; # this is for fcitx5
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
