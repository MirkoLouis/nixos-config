{
  description = "Declarative NixOS Flake Configuration for MirkoInNIXOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    # Add Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Add the target dotfiles repository
    dotfiles-43pr = {
      url = "github:43PR/dotfiles";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, chaotic, home-manager, ... }@inputs: {
    nixosConfigurations = {
      MirkoInNIXOS = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          chaotic.nixosModules.default

          # Initialize Home Manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # Pass inputs to Home Manager modules
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.mirkolouis = import ./home.nix;
          }
        ];
      };
    };
  };
}
