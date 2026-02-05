# K3s agent (worker node) module
# Import this via: inputs.home-lab.nixosModules.k3s-agent
#
# Usage in your host configuration:
#   imports = [ inputs.home-lab.nixosModules.k3s-agent ];
#   services.k3s.serverAddr = "https://control-plane:6443";
#   services.k3s.tokenFile = /path/to/token;
{ config, pkgs, lib, ... }:

{
  imports = [ ./base.nix ];

  # K3s agent configuration
  services.k3s = {
    enable = true;
    role = "agent";
    # serverAddr and tokenFile must be set in the host configuration
    # Example:
    #   services.k3s.serverAddr = "https://192.168.1.10:6443";
    #   services.k3s.tokenFile = /var/lib/k3s/token;
  };

  # Agent firewall rules (base.nix covers most, API access to server)
  networking.firewall.allowedTCPPorts = [
    6443   # Kubernetes API (for kubectl from worker)
  ];
}
