# K3s base module - shared configuration for both server and agent roles
# Import this via: inputs.home-lab.nixosModules.k3s-base
{ config, pkgs, lib, ... }:

{
  # Required kernel modules for container networking and storage
  boot.kernelModules = [
    "br_netfilter"
    "ip_vs"
    "ip_vs_rr"
    "ip_vs_wrr"
    "ip_vs_sh"
    "overlay"
    "iscsi_tcp"
  ];

  # Sysctl settings for Kubernetes networking
  boot.kernel.sysctl = {
    "net.bridge.bridge-nf-call-iptables" = 1;
    "net.bridge.bridge-nf-call-ip6tables" = 1;
    "net.ipv4.ip_forward" = 1;
  };

  # Base firewall rules (both server and agent need these)
  networking.firewall = {
    allowedTCPPorts = [
      10250  # Kubelet metrics
    ];
    allowedUDPPorts = [
      8472   # Flannel VXLAN
    ];
  };

  # Longhorn requires open-iscsi
  services.openiscsi = {
    enable = true;
    name = "iqn.2025-01.org.nixos:initiator";
  };

  # Longhorn uses nsenter to find iscsiadm on the host at standard paths.
  # NixOS puts binaries in /nix/store, so we symlink to where Longhorn expects them.
  systemd.tmpfiles.rules = [
    "L+ /usr/local/bin/iscsiadm - - - - ${pkgs.openiscsi}/bin/iscsiadm"
  ];

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
