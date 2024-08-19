{...}: {
  imports = [./knightpp.nix];

  config = {
    users.users = {
      root = {
        initialHashedPassword = "$6$pgzhN8I3kJ1O35mZ$dzoVn596Htt3Jc7S1ftGyRnoxHmqvNpY.ZKtN3c/j5y0K3ZlbpwbaMaA6Mw5XnuVQxrDQ0184dkMtZp98thXU1";
      };
    };
    users.groups = {
      plugdev = {};
      nixoscfg = {};
    };
  };
}
