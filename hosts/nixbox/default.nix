{
  lib,
  config,
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
      config
      .pkgs
      .unstable
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
                    owner = "SergioGasquez";
                    repo = "espflash";
                    rev = "fix/resets";
                    sha256 = "sha256-eSj+NX2yhYqKakR6jhng88uXLheiLJj4fibxyCMzfFs=";
                  };
                  cargoHash = "sha256-/xK5vb819QrOg/y6u/pFPsQbsbMJiApK6fKyeYuKO/0=";
                });
          };
      });
  };

  environment.systemPackages = let
    lutris = config.pkgs.unstable.lutris.override {
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
        nix-init
        ;

      inherit
        (config.pkgs.unstable)
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

  # To dump logs use journalctl --unit nvme-smart-log.service --output json
  systemd.timers."nvme-smart-log" = {
    description = "Timer to trigger NVME smart log collection on daily basis";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      Unit = "nvme-smart-log.service";
    };
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
