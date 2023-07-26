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
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Module 0: zfs-root
            ./modules

            # Module 2: entry point
            {
              system.configurationRevision =
                if (self ? rev) then
                  self.rev
                else
                  throw "refuse to build: git tree is dirty";
              system.stateVersion = "23.05";
              imports = [
                "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
                # "${nixpkgs}/nixos/modules/profiles/hardened.nix"
                # "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
              ];
            }

            # Module 3: home-manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }

            # Module 4: config shared by all hosts
            ./configuration.nix

            # Module 5: add nixpkgs
            (
              let
                inherit (nixpkgs) lib;
                optType = lib.mkOptionType {
                  name = "nixpkgs";
                  description = "An evaluation of Nixpkgs; the top level attribute set of packages";
                  check = builtins.isAttrs;
                };
              in
              {
                options.pkgs.unstable = lib.mkOption { type = optType; };
                config.pkgs.unstable = lib.mkDefault (import unstable {
                  config = { allowUnfree = true; };
                  inherit system;
                });
              }
            )

            # Module 6: host
            ./hosts/${hostName}

            # Module 7: users
            ./users
          ];
        };
    in
    {
      nixosConfigurations = {
        nixbox = mkHost "nixbox" "x86_64-linux";
      };
    };
}
