# K3s server (control plane) module
# Import this via: inputs.home-lab.nixosModules.k3s-server
#
# Usage in your host configuration:
#   imports = [ inputs.home-lab.nixosModules.k3s-server ];
#   services.k3s.extraFlags = toString [ "--disable=traefik" ];
{ config, pkgs, lib, ... }:

{
  imports = [ ./base.nix ];

  # K3s server configuration
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--disable=traefik"             # Use ingress-nginx instead
      "--disable=servicelb"           # Manage load balancing separately
      "--write-kubeconfig-mode=644"   # Allow non-root kubectl access
    ];
  };

  # Control plane firewall rules
  networking.firewall.allowedTCPPorts = [
    6443   # Kubernetes API server
    2379   # etcd client
    2380   # etcd peer
  ];
}
