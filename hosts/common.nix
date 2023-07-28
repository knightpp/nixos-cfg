# configuration in this file is shared by all hosts
{ config, pkgs, lib, ... }: {
  nixpkgs.config.allowUnfree = true;

  # TODO: Do I need rtkit?
  security.rtkit.enable = true;

  services.openssh = {
    enable = true;
    settings = { PasswordAuthentication = false; };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  security = {
    sudo.enable = false;

    doas = {
      enable = true;
      extraRules = [{
        users = [ "knightpp" ];
        keepEnv = true;
        persist = true;
      }];
    };
  };

  fonts = lib.mkIf config.desktop-environment.enable {
    fonts = builtins.attrValues {
      inherit (pkgs)
        noto-fonts
        noto-fonts-emoji
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        ;

      nerdfonts = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
    };

    fontconfig = {
      # seems doesn't do anything
      allowBitmaps = false;
    };
  };

  # disable command-not-found handler for everyone since it's annoying and doesn't work with flakes
  # If you ever need it, you can use a replacement 'nix-index' from home-manager
  programs.command-not-found.enable = false;

  # This is needed to set fish as login shell
  programs.fish.enable = true;

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      fzf
      file
      git
      nushell
      nfs-utils
      ripgrep
      du-dust
      fd
      tokei
      ;
    inherit (pkgs.fishPlugins) # install fish plugins system wide
      fzf-fish
      autopair
      done
      ;
  };

  services.rpcbind.enable = true; # needed for NFS
  systemd.mounts = [{
    type = "nfs";
    mountConfig = {
      Options = "noatime";
    };
    what = "opi.lan:/";
    where = "/mnt/opi";
  }];

  systemd.automounts = [{
    wantedBy = [ "multi-user.target" ];
    automountConfig = {
      TimeoutIdleSec = "300";
    };
    where = "/mnt/opi";
  }];
}
