{
  lib,
  config,
  pkgs,
  ...
}: {
  zfs-root = {
    boot = {
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
    cargo-espflash = config.pkgs.unstable.cargo-espflash.overrideAttrs (old: rec {
      version = "git";
      src = pkgs.fetchFromGitHub {
        owner = "AVee";
        repo = "espflash";
        rev = "add_unix_tight_reset";
        sha256 = "sha256-aNl5V/H9q1+sutTgBBrzfd6M+GeAUhZ8N78MeQE8TOk=";
      };

      cargoDeps = old.cargoDeps.overrideAttrs (_: {
        inherit src;

        outputHash = "sha256-Pu6L7pLRBDQX40I4a5u5e5ic8+ePVM4Yvgq4qSZHDMo=";
      });
    });
  };

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      nix-index
      cargo-espflash
      ;
  };

  hardware.cpu.amd.updateMicrocode = true;

  boot.zfs.forceImportRoot = false;

  desktop-environment.kde.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
    extraPackages = [pkgs.zfs];
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

  systemd.services."nvme-smart-log" = {
    script = ''
      set -euo pipefail
      ${pkgs.smartmontools}/bin/smartctl --json=c -a /dev/nvme0
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };

  # enable fn keys on nuphy keyboard
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=0
  '';
}
