{
  config,
  sops-nix,
  ...
}: {
  sops.defaultSopsFile = ./../../secrets/secrets.yaml;
  # This will automatically import SSH keys as age keys
  # sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  # This is the actual specification of the secrets.
  sops.secrets.github_token = {
    mode = "0440";
    # group = config.users.groups.keys.name;
  };
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      !include ${config.sops.secrets.github_token.path}
    '';
  };
}
