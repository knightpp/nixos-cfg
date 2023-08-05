{...}: {
  # See available home-manager options here https://nix-community.github.io/home-manager/options.html
  imports = [./knightpp];

  config = {
    users.users.root.initialHashedPassword = "$6$pgzhN8I3kJ1O35mZ$dzoVn596Htt3Jc7S1ftGyRnoxHmqvNpY.ZKtN3c/j5y0K3ZlbpwbaMaA6Mw5XnuVQxrDQ0184dkMtZp98thXU1";

    # This group is allowed to write to /etc/nixos
    users.groups.nixoscfg = {};
    home-manager.sharedModules = [./shared.nix];
  };
}
