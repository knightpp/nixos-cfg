{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-24.05";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    # hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    sops-nix,
    nix-index-database,
    ...
  } @ inputs: let
    mkHost = hostName: system:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          ./modules

          sops-nix.nixosModules.sops

          {
            imports = [nix-index-database.nixosModules.nix-index];
            config = {
              programs.nix-index-database.comma.enable = true;
            };
          }

          {
            system.configurationRevision =
              if self ? rev
              then self.rev
              else "dirty";
            # system.configurationRevision =
            #   if (self ? rev)
            #   then self.rev
            #   else throw "refuse to build: git tree is dirty";
            system.stateVersion = "23.11";
            imports = [
              "${nixpkgs}/nixos/modules/installer/scan/not-detected.nix"
            ];
          }

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          }

          ./hosts/common.nix

          ./hosts/${hostName}

          ./users
        ];
      };
  in {
    nixosConfigurations = {
      nixbox = mkHost "nixbox" "x86_64-linux";
      chlap = mkHost "chlap" "x86_64-linux";
      porta = mkHost "porta" "x86_64-linux";
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

        ${pkgs.nvd}/bin/nvd diff "''${beforeLast}" "''${last}"
      '';
  };
}
