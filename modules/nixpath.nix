{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.modules.nixpath;
  nixpkgs = inputs.nixpkgs;
in {
  options = {
    modules.nixpath = {
      enable = lib.mkOption {
        default = true;
        example = false;
        description = "Sets nixpath and nix registry to allow nix-shell and nix use 'nixpkgs' as an alias to the nixpkgs revision used in this flake";
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      nixPath = lib.mkDefault ["nixpkgs=${nixpkgs}"];
      registry.nixpkgs.flake = lib.mkDefault nixpkgs;
    };
  };
}
