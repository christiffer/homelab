# Control Plane host configuration
{ config, pkgs, ... }:

{
  # Import hardware configuration (generated during install)
  # imports = [ ./hardware-configuration.nix ];

  # Hostname
  networking.hostName = "control-plane";

  # Network configuration
  # TODO: Configure static IP after hardware setup
  # networking.interfaces.eth0.ipv4.addresses = [{
  #   address = "192.168.1.10";
  #   prefixLength = 24;
  # }];
  # networking.defaultGateway = "192.168.1.1";
  # networking.nameservers = [ "192.168.1.1" ];

  # K3s as server (control plane)
  services.k3s = {
    role = "server";
    extraFlags = toString [
      "--disable=traefik"      # We'll use nginx-ingress
      "--disable=servicelb"    # We'll manage load balancing
      "--write-kubeconfig-mode=644"  # Allow non-root kubectl access
    ];
  };

  # Additional firewall rules for control plane
  networking.firewall.allowedTCPPorts = [
    2379  # etcd client
    2380  # etcd peer
  ];

  # User configuration
  # TODO: Add your user and SSH keys
  # users.users.admin = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ];
  #   openssh.authorizedKeys.keys = [
  #     "ssh-ed25519 AAAA..."
  #   ];
  # };
}
