# K3s configuration module
{ config, pkgs, lib, ... }:

{
  # K3s service
  services.k3s = {
    enable = true;
    # Role is set per-host: "server" for control plane, "agent" for workers
    # role = "server";  # Set in host configuration

    # For server role, these are common settings
    # extraFlags = toString [
    #   "--disable traefik"  # We'll use nginx-ingress instead
    #   "--disable servicelb"  # We'll handle this ourselves
    # ];
  };

  # Firewall rules for K3s
  networking.firewall = {
    allowedTCPPorts = [
      6443  # Kubernetes API server
      10250 # Kubelet metrics
    ];

    # Additional ports for control plane
    # allowedTCPPorts = [
    #   2379  # etcd client
    #   2380  # etcd peer
    # ];

    # Flannel VXLAN
    allowedUDPPorts = [
      8472
    ];
  };

  # Required kernel modules for container networking
  boot.kernelModules = [
    "br_netfilter"
    "ip_vs"
    "ip_vs_rr"
    "ip_vs_wrr"
    "ip_vs_sh"
    "overlay"
  ];

  # Sysctl settings for Kubernetes
  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
    "net.ipv4.ip_forward" = 1;
  };

  # Packages needed for K3s operation
  environment.systemPackages = with pkgs; [
    k3s
    kubectl
    kubernetes-helm
  ];

  # kubectl alias for convenience
  programs.bash.shellAliases = {
    k = "kubectl";
  };
}
