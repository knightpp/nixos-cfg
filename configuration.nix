# configuration in this file is shared by all hosts
{ pkgs, ... }: {
  networking.useDHCP = false;
  networking.networkmanager.enable = true;
  nixpkgs.config.allowUnfree = true;


  environment = {
    sessionVariables = {
      SSH_ASKPASS_REQUIRE = "prefer";
    };
  };

  desktop-environment.kde.enable = true;

  security.rtkit.enable = true;

  services.openssh = {
    enable = true;
    settings = { PasswordAuthentication = false; };
  };

  boot.zfs.forceImportRoot = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  security = {
    doas.enable = true;
    sudo.enable = false;
  };

  security.doas.extraRules = [{
    users = [ "knightpp" ];
    keepEnv = true;
    persist = true;
  }];

  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      git
      nushell
      nfs-utils
      ripgrep
      du-dust
      fd
      tokei
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
