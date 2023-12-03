{
  lib,
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

  zfs-root = {
    boot = {
      enable = true;
      devNodes = "/dev/disk/by-id/";
      bootDevices = ["nvme-Samsung_SSD_980_500GB_S64DNL0T949034V"];
      immutable = false;
      availableKernelModules = ["xhci_pci" "ahci" "nvme" "usbhid" "uas" "sd_mod"];
      removableEfi = true;
      kernelParams = [];
      sshUnlock = {
        enable = false;
        authorizedKeys = [];
      };
    };
    networking = {
      hostName = "nixbox";
      timeZone = "Europe/Kyiv";
      hostId = "fcf7de2a";
    };
  };

  # enables to write Japanese
  i18n.inputMethod.enabled = "fcitx5";
  i18n.inputMethod.fcitx5.addons = builtins.attrValues {inherit (pkgs) fcitx5-mozc;};

  nixpkgs.config.packageOverrides = pkgs: {
    cargo-espflash =
      pkgs
      .cargo-espflash
      .override (old: {
        rustPlatform =
          old.rustPlatform
          // {
            buildRustPackage = args:
              old.rustPlatform.buildRustPackage (args
                // {
                  version = "git";
                  src = pkgs.fetchFromGitHub {
                    owner = "esp-rs";
                    repo = "espflash";
                    rev = "71d7a630275965d47219048c371702bc587de152";
                    sha256 = "sha256-zF8rtjSRu7BBg4tRw3rvAXEzmAbW4lF6xBT5Teh2wFI=";
                  };
                  cargoHash = "sha256-NxtGAgPKsoVF77tJfVQHstljpW1ZaptOk0fa3L+HCaQ=";
                });
          };
      });
  };

  environment.systemPackages = let
    lutris = pkgs.lutris.override {
      extraPkgs = pkgs: [
        pkgs.wget
      ];
    };
  in
    builtins.attrValues {
      inherit ffmpeg-full;
      inherit lutris;

      inherit
        (pkgs)
        cargo-espflash
        blender
        cura
        nix-init
        librepcb
        ;
    };

  hardware.cpu.amd.updateMicrocode = true;
  hardware.bluetooth.enable = true;

  boot.zfs.forceImportRoot = false;

  desktop-environment.user = "knightpp";
  desktop-environment.kde.enable = true;

  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
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
  services.flatpak.enable = true;

  workarounds.flatpak.enable = true;
  workarounds.steam.enable = true;
  repl.enable = true;

  boot.extraModprobeConfig = let
    # enable fn keys on nuphy keyboard
    keyboardOpts = "fnmode=0";
    zfsOpts = [
      "zfs_dirty_data_max_percent=50"
      "zfs_dirty_data_max_max_percent=60"

      "zfs_dirty_data_sync_percent=30"

      "zfs_txg_timeout=120" # 120 seconds between commits
    ];
  in ''
    options hid_apple ${keyboardOpts}
    options zfs ${lib.strings.concatStringsSep " " zfsOpts}
  '';
}
