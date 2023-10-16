# configuration in this file is shared by all hosts
{pkgs, ...}: let
  keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG86t/Sa1mUjJtz7my7fhS0UvK3za5JCOyTw4u58rwvv Personal SSH"];
in {
  nixpkgs.config.allowUnfree = true;

  # TODO: Do I need rtkit?
  security.rtkit.enable = true;

  services.openssh = {
    enable = true;
    settings = {PasswordAuthentication = false;};
  };

  nix = {
    settings.experimental-features = ["nix-command" "flakes"];

    # connect-timeout and fallback are needed when some sibstituters become offline, so
    # we won't wait indefinitely and fail.
    extraOptions = ''
      connect-timeout = 1
      log-lines = 25
      fallback = true
    '';

    sshServe = {
      enable = true;
      protocol = "ssh-ng";
      keys = keys;
    };

    settings = {
      extra-trusted-public-keys = keys;
    };
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
}
