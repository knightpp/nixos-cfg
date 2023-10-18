{
  config,
  lib,
  ...
}: let
  cfg = config.modules.nix-serve;
  self = config.networking.hostName;
  hostNames = builtins.filter (x: x != self) cfg.hostNames;
in {
  options.modules.nix-serve = {
    enable = lib.mkEnableOption "Nix serve";

    # TODO: rework to accept hosts option like: { host1 = "pubkeyy"; host2 = "pubkey"; } ?
    pubKey = lib.mkOption {
      description = "SSH public key";
      type = lib.types.str;
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAB+Ic2tILAPaNb6Kxzl8NypY9hZ/yANQ3izUzhh8yGd nix-ssh";
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
      AuthenticationMethods publickey
    '';

    programs.ssh = {
      knownHosts = lib.attrsets.genAttrs (map (h: "${h}.lan") hostNames) (_: {
        publicKey = cfg.pubKey;
      });

      extraConfig =
        lib
        .concatLines
        (builtins
          .map (host: ''
            Host ${host}
              HostName ${host}.lan
              User nix-ssh

              IdentitiesOnly yes
              IdentityFile ${config.sops.secrets.ssh-key.path}
            Host *
          '')
          hostNames);
    };

    nix = let
      protocol = "ssh-ng";
    in {
      sshServe = {
        enable = true;
        protocol = protocol;
        keys = [cfg.pubKey];
      };

      settings = {
        extra-trusted-public-keys = [cfg.pubKey];
        substituters = map (x: "${protocol}://nix-ssh@${x}.lan") hostNames;
      };
    };
  };
}
