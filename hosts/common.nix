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

  modules.nix-serve = {
    enable = true;
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
      keep-outputs = true
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

  # disable command-not-found handler for everyone since it's annoying and doesn't work with flakes
  # If you ever need it, you can use a replacement 'nix-index' from home-manager
  programs.command-not-found.enable = false;

  # This is needed to set fish as login shell
  programs.fish.enable = true;

  environment.sessionVariables = {
    EDITOR = "${pkgs.helix}/bin/hx";
  };

  environment.systemPackages = builtins.attrValues {
    inherit
      (pkgs)
      fzf
      file
      git
      nushell
      nfs-utils
      ripgrep
      du-dust
      fd
      tokei
      smartmontools
      alejandra
      nixpkgs-fmt
      age
      sops
      helix
      nixpkgs-lint
      cachix
      nil
      kicad
      ;
    inherit
      (pkgs.fishPlugins) # install fish plugins system wide
      fzf-fish
      autopair
      done
      ;
  };

  services.rpcbind.enable = true; # needed for NFS
  systemd.mounts = [
    {
      type = "nfs";
      mountConfig = {
        Options = "noatime,nofail,noauto";
      };
      what = "opi.lan:/";
      where = "/mnt/opi";
    }
  ];

  systemd.automounts = [
    {
      wantedBy = ["multi-user.target"];
      automountConfig = {
        TimeoutIdleSec = "300";
      };
      where = "/mnt/opi";
    }
  ];

  # TODO: remove this after some time
  nixpkgs.config.permittedInsecurePackages = [
    "electron-24.8.6"
  ];
}
