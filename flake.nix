{
  description = "Declarative NixOS Flake Configuration for MirkoInNIXOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
  };

  outputs = { self, nixpkgs, chaotic, ... }@inputs: {
    nixosConfigurations = {
      MirkoInNIXOS = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          chaotic.nixosModules.default
        ];
      };
    };
  };
}
