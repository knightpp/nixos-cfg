{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-23.05";
    };
    unstable = {
      url = "github:nixos/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, unstable }:
    let
      mkHost = hostName: system:
        (
          ({ my-config, zfs-root, pkgs, system, ... }:
            nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                # Module 0: zfs-root and my-config
                ./modules

                # Module 1: host-specific config, if exist
                (if (builtins.pathExists
                  ./hosts/${hostName}/configuration.nix) then
                  (import ./hosts/${hostName}/configuration.nix { inherit pkgs; })
                else
                  { })

                # Module 2: entry point
                (({ my-config, zfs-root, pkgs, lib, ... }: {
                  inherit my-config zfs-root;
                  system.configurationRevision =
                    if (self ? rev) then
                      self.rev
                    else
                      throw "refuse to build: git tree is dirty";
                  system.stateVersion = "23.05";
                  #		nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
                  #             		"vscode"
                  #           	];
                  imports = [
                    "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
                    # "${nixpkgs}/nixos/modules/profiles/hardened.nix"
                    # "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
                  ];
                }) {
                  inherit my-config zfs-root pkgs;
                  lib = nixpkgs.lib;
                })

                # Module 3: home-manager
                home-manager.nixosModules.home-manager
                {
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                }

                # Module 4: config shared by all hosts
                (import ./configuration.nix {
                  inherit pkgs;
                })

                # Module 5: add unstable nixpkgs
                (
                  let
                    inherit (nixpkgs) lib;
                  in
                  {
                    options.nixpkgs.unstable = lib.mkOption {
                      type = lib.mkOptionType {
                        name = "nixpkgs";
                        description = "An evaluation of Nixpkgs; the top level attribute set of packages";
                        check = builtins.isAttrs;
                      };
                    };
                    config.nixpkgs.unstable = lib.mkDefault (import unstable {
                      config = { allowUnfree = true; };
                      inherit system;
                    });
                  }
                )
              ];
            })

            # configuration input
            (import ./hosts/${hostName} {
              system = system;
              #pkgs = nixpkgs.legacyPackages.${system};
              # see https://github.com/ne9z/dotfiles-flake/issues/4
              # there's a bug in 23.05 which prevents allowUnfree to work normally
              pkgs = import nixpkgs {
                config = { allowUnfree = true; };
                inherit system;
              };
            }));
    in
    {
      nixosConfigurations = {
        nixbox = mkHost "nixbox" "x86_64-linux";
      };
    };
}
