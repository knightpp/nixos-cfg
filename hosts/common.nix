# configuration in this file is shared by all hosts
{pkgs, ...}: {
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

    # fancier nix command
    nh = {
      enable = true;
      flake = "/etc/nixos";
    };

    ssh = {
      extraConfig = ''
        Host *.lan
          ForwardAgent yes
        Host *
      '';
    };
  };
  modules.nix-serve = {
    enable = false;
    hostNames = ["chlap" "nixbox"];
  };

  networking.networkmanager.wifi.backend = "iwd";

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];

    # connect-timeout and fallback are needed when some sibstituters become offline, so
    # we won't wait indefinitely and fail.
    # see https://jackson.dev/post/nix-reasonable-defaults/
    extraOptions = ''
      connect-timeout = 1
      log-lines = 25
      fallback = true
      auto-optimise-store = true
    '';
  };

  boot = {
    tmp.useTmpfs = true;
    kernel.sysctl = {
      "vm.swappiness" = 5;
      "vm.dirty_background_ratio" = 50;
      "vm.dirty_ratio" = 50;
      "vm.dirty_expire_centisecs" = 120 * 100;
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
      git # this should be in system packages since nix depends on i/*  */t
      file
      nfs-utils
      age
      sops
      gparted
      usbutils
      pciutils
      ;
  };

  i18n.supportedLocales = map (x: x + "/UTF-8") [
    "en_US.UTF-8"
    "en_GB.UTF-8"
    "uk_UA.UTF-8"
  ];

  services.udev.packages = [pkgs.picoprobe-udev-rules];
  hardware.keyboard.qmk.enable = true;
  modules.zsa-udev-rules.enable = true;
  hardware.keyboard.zsa.enable = false; # the rules does not include Voyager, have to hardcode newer rules

  services.rpcbind.enable = true; # needed for NFS
  systemd.mounts = [
    {
      type = "nfs";
      mountConfig = {
        Options = "noatime,nofail,noauto";
      };
      what = "alta.lan:/media";
      where = "/mnt/media";
    }
  ];

  systemd.automounts = [
    {
      wantedBy = ["multi-user.target"];
      automountConfig = {
        TimeoutIdleSec = "300";
      };
      where = "/mnt/media";
    }
  ];
}
