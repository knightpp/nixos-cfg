{...}: {
  # See available home-manager options here https://nix-community.github.io/home-manager/options.html
  imports = [./knightpp];

  config = {
    # This groups is allowed to write to /etc/nixos
    users.groups.nixoscfg = {};
    home-manager.sharedModules = [./shared.nix];
  };
}
