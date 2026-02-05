{
  description = "Home Lab NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs: {
    nixosConfigurations = {
      # K3s control plane (x86 server)
      control-plane = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/control-plane/configuration.nix
          ./modules/common.nix
          ./modules/k3s.nix
        ];
      };

      # Future NUC worker node template
      nuc-worker = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nuc-worker/configuration.nix
          ./modules/common.nix
          ./modules/k3s.nix
        ];
      };
    };
  };
}
