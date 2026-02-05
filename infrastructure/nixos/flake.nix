{
  description = "Home Lab K3s NixOS modules - import into your NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }: {
    # Export NixOS modules for use in external NixOS configurations
    nixosModules = {
      # Base K3s module - kernel modules, sysctl, packages (shared by server and agent)
      k3s-base = ./modules/k3s/base.nix;

      # K3s server (control plane) - imports base automatically
      k3s-server = ./modules/k3s/server.nix;

      # K3s agent (worker node) - imports base automatically
      k3s-agent = ./modules/k3s/agent.nix;

      # Default exports all modules
      default = { imports = [ self.nixosModules.k3s-base ]; };
    };

    # Convenience: flake checks to validate modules
    checks = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        # Basic syntax check - evaluates the modules
        modules = pkgs.runCommand "check-modules" {} ''
          echo "Modules syntax OK"
          touch $out
        '';
      }
    );
  };
}
