{
  config,
  lib,
  ...
}: let
  cfg = config.modules.nix-serve;
in {
  options.modules.nix-serve = {
    enable = lib.mkEnableOption "Nix serve";

    keys = lib.mkOption {
      description = "SSH public keys";
      type = lib.types.nonEmptyListOf lib.types.str;
      default = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAB+Ic2tILAPaNb6Kxzl8NypY9hZ/yANQ3izUzhh8yGd nix-ssh"];
    };

    hostNames = lib.mkOption {
      type = lib.types.nonEmptyListOf lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.ssh-key = {
      mode = "0400";
      owner = config.users.users.nix-ssh.name;
      group = config.users.users.nix-ssh.group;
      sopsFile = ./../secrets/nix-serve-ssh-key.yaml;
    };

    services.openssh.extraConfig = ''
      HostKey ${config.sops.secrets.ssh-key.path}
    '';

    # flake.nixosConfigurations.chlap.config.networking.hostName

    nix = {
      sshServe = {
        enable = true;
        protocol = "ssh-ng";
        keys = cfg.keys;
      };

      settings = {
        extra-trusted-public-keys = cfg.keys;
        substituters = let
          self = config.networking.hostName;
          hostNames = builtins.filter (x: x != self) cfg.hostNames;
          urls = map (x: "ssh://nix-ssh@${x}.lan") hostNames;
        in
          urls;
      };
    };
  };
}
