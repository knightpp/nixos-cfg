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

  users.users = {
    root = {
      initialHashedPassword = "$6$pgzhN8I3kJ1O35mZ$dzoVn596Htt3Jc7S1ftGyRnoxHmqvNpY.ZKtN3c/j5y0K3ZlbpwbaMaA6Mw5XnuVQxrDQ0184dkMtZp98thXU1";
    };
    knightpp = {
      isNormalUser = true;
      group = "knightpp";
      extraGroups = [ "nixoscfg" ];
      initialHashedPassword = "$6$pgzhN8I3kJ1O35mZ$dzoVn596Htt3Jc7S1ftGyRnoxHmqvNpY.ZKtN3c/j5y0K3ZlbpwbaMaA6Mw5XnuVQxrDQ0184dkMtZp98thXU1";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG86t/Sa1mUjJtz7my7fhS0UvK3za5JCOyTw4u58rwvv Personal SSH"
      ];
    };
  };
  users.groups = {
    knightpp = { };
    nixoscfg = { };
  };

  desktop-environment.kde.enable = true;

  security.rtkit.enable = true;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  services.openssh = {
    enable = true;
    settings = { PasswordAuthentication = false; };
  };

  boot.zfs.forceImportRoot = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.git.enable = true;

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
      nushell
      fish
      nfs-utils
      starship
      ripgrep
      du-dust
      fd
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
