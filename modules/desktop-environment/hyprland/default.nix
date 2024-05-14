{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.desktop-environment.hyprland;
in {
  options = {
    desktop-environment.hyprland = {
      enable = lib.mkEnableOption "Hyprland";
    };
  };

  config = lib.mkIf cfg.enable {
    desktop-environment.enable = true;

    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    };

    # hint electron apps to use wayland:
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
    environment.systemPackages = builtins.attrValues {
      inherit
        (pkgs)
        neovim
        kitty # terminal
        mako # notification daemon
        waybar # status bar
        tofi # launcher minimalistic
        rofi-wayland # launcher popular
        ;

      inherit (pkgs.libsForQt5) polkit-kde-agent; # Auth agent
    };

    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };
  };
}
