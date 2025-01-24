# configuration in this file is shared by all hosts
{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-index-database.nixosModules.nix-index
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  programs.nix-index-database.comma.enable = true;

  nixpkgs.config.allowUnfree = true;

  # TODO: Do I need rtkit?
  security.rtkit.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  programs = {
    # disable command-not-found handler for everyone since it's annoying and doesn't work with flakes
    # If you ever need it, you can use a replacement 'nix-index' from home-manager
    command-not-found.enable = false;
    adb.enable = true;
  };

  modules = {
    users.knightpp.enable = true;
    nixpkgs-unstable.enable = true;
    nix-serve = {
      enable = false;
      hostNames = ["chlap" "nixbox"];
    };
  };

  networking.networkmanager.wifi.backend = "iwd";

  boot = {
    tmp.useTmpfs = true;
    kernel.sysctl = {
      "vm.swappiness" = 5;
      "vm.dirty_background_ratio" = 50;
      "vm.dirty_ratio" = 50;
      "vm.dirty_expire_centisecs" = 120 * 100;
      # QUIC increase UDP buffer size
      # "net.core.rmem_max" = 7500000;
      # "net.core.wmem_max" = 7500000;
    };
  };

  security = {
    sudo.enable = false;

    doas = {
      enable = true;
      extraRules = [
        {
          users = ["knightpp"];
          keepEnv = true;
          persist = true;
        }
      ];
    };
  };

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      compsize # check btrfs compression
      git # this should be in system packages since nix depends on it
      file
      nfs-utils
      age
      sops
      usbutils
      pciutils
      inotify-tools
      distrobox
      btrfs-progs
      doas-sudo-shim # to use with nixos-rebuild --use-remote-sudo
      nvme-cli
      smartmontools # provides smartctl
      ;
  };

  services.fwupd.enable = true;

  i18n.supportedLocales = map (x: x + "/UTF-8") [
    "en_US.UTF-8"
    "en_GB.UTF-8"
    "uk_UA.UTF-8"
  ];

  time.timeZone = "Europe/Kyiv";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  services.udev.packages = [pkgs.picoprobe-udev-rules];
  hardware.keyboard.qmk.enable = true;
  modules.zsa-udev-rules.enable = true;
  hardware.keyboard.zsa.enable = false; # the rules does not include Voyager, have to hardcode newer rules
}
