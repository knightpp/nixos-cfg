{
  config,
  lib,
  ...
}: {
  sops.defaultSopsFile = ./../../secrets/secrets.yaml;
  # This will automatically import SSH keys as age keys
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  sops.secrets = {
    githubToken = {
      mode = "0440";
      group = config.users.groups.keys.name;
    };

    nixAccessTokens = {
      mode = "0440";
      group = config.users.groups.keys.name;
    };
  };

  nix = {
    extraOptions = ''
      !include ${config.sops.secrets.nixAccessTokens.path}
    '';
  };
}
