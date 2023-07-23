{ pkgs, ... }: {
  # configuration in this file only applies to exampleHost host.
  # programs.tmux = {
  #   enable = true;
  #   newSession = true;
  #   terminal = "tmux-direct";
  # };
  # services.emacs.enable = false;

  # enable fn keys on nuphy keyboard
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=0
  '';
}
