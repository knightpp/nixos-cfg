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

  outputs = {
    self,
    nixpkgs,
    home-manager,
    unstable,
  }: let
    mkHost = hostName: system:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # Module 0: zfs-root
          ./modules

          # Module 2: entry point
          {
            system.configurationRevision =
              if (self ? rev)
              then self.rev
              else throw "refuse to build: git tree is dirty";
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
          ./hosts/common.nix

          # Module 5: add nixpkgs
          (
            let
              inherit (nixpkgs) lib;
              optType = lib.mkOptionType {
                name = "nixpkgs";
                description = "An evaluation of Nixpkgs; the top level attribute set of packages";
                check = builtins.isAttrs;
              };
            in {
              options.pkgs.unstable = lib.mkOption {type = optType;};
              config.pkgs.unstable = lib.mkDefault (import unstable {
                config = {allowUnfree = true;};
                inherit system;
              });
            }
          )

          # HACK: temporary workaround for flatpak
          (
            {
              config,
              pkgs,
              ...
            }: {
              system.fsPackages = [pkgs.bindfs];
              fileSystems = let
                mkRoSymBind = path: {
                  device = path;
                  fsType = "fuse.bindfs";
                  options = ["ro" "resolve-symlinks" "x-gvfs-hide"];
                };
                aggregated = pkgs.buildEnv {
                  name = "system-fonts-and-icons";
                  paths = builtins.attrValues {
                    inherit (pkgs.libsForQt5) breeze-qt5;
                    inherit
                      (pkgs)
                      noto-fonts
                      noto-fonts-emoji
                      noto-fonts-cjk-sans
                      noto-fonts-cjk-serif
                      ;
                  };
                  pathsToLink = ["/share/fonts" "/share/icons"];
                };
              in {
                # Create an FHS mount to support flatpak host icons/fonts
                "/usr/share/icons" = mkRoSymBind "${aggregated}/share/icons";
                "/usr/share/fonts" = mkRoSymBind "${aggregated}/share/fonts";
              };
            }
          )

          # Module 6: host
          ./hosts/${hostName}

          # Module 7: users
          ./users
        ];
      };
  in {
    nixosConfigurations = {
      nixbox = mkHost "nixbox" "x86_64-linux";
    };
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
