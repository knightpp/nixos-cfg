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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    unstable,
    home-manager,
    sops-nix,
  }: let
    mkHost = hostName: system:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./modules

          {
            imports = [sops-nix.nixosModules.sops];
          }

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

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }

          ./hosts/common.nix

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

          ./hosts/${hostName}

          ./users

          ({pkgs, ...}: {
            nix.nixPath = ["nixpkgs=${nixpkgs}"];
            environment.systemPackages = let
              repl_path = toString ./.;
              systemRepl = pkgs.writeShellScriptBin "repl" ''
                source /etc/set-environment
                nix repl "${repl_path}/repl.nix" "$@"
              '';
            in [
              systemRepl
            ];
          })
        ];
      };
  in {
    nixosConfigurations = {
      nixbox = mkHost "nixbox" "x86_64-linux";
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;

    diff = let
      pkgs = import nixpkgs {system = "x86_64-linux";};
    in
      pkgs.writeShellScriptBin "diff" ''
        shopt -s nullglob

        generations=(/nix/var/nix/profiles/system-*-link)

        last=''${generations[-1]}
        beforeLast=''${generations[-2]}

        echo "Boot system is $(readlink /nix/var/nix/profiles/system)"
        echo "Comparing"
        echo -e "\t''${beforeLast}"
        echo -e "\t''${last}"
        echo ""

        nix store diff-closures "''${beforeLast}" "''${last}"
      '';
  };
}
