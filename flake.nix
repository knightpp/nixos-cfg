{
  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs?ref=nixos-24.11";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs?ref=nixos-unstable-small";
    };
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
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
      url = "github:NixOS/nixos-hardware?ref=master";
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
          ./services

          {
            networking.hostName = hostName;
            nixpkgs.hostPlatform = system;
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
            system.stateVersion = "24.11";
          }

          ./hosts/common.nix

          ./hosts/${hostName}

          ./users
        ];
      };

    forAllSystems = f:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ] (system: f (nixpkgs.legacyPackages."${system}"));
  in {
    nixosConfigurations = {
      nixbox = mkHost "nixbox" "x86_64-linux";
      chlap = mkHost "chlap" "x86_64-linux";
      porta = mkHost "porta" "x86_64-linux";
      potato = mkHost "potato" "aarch64-linux";
      alta = mkHost "alta" "aarch64-linux";
    };

    formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);

    packages = forAllSystems (pkgs: {
      diff = pkgs.writeShellScriptBin "diff" ''
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
    });
  };
}
