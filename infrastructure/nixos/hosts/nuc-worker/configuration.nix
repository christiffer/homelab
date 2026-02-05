# NUC Worker node configuration (template for future use)
{ config, pkgs, ... }:

{
  # Import hardware configuration (generated during install)
  # imports = [ ./hardware-configuration.nix ];

  # Hostname - change for each NUC
  networking.hostName = "nuc-worker-1";

  # Network configuration
  # TODO: Configure static IP after hardware setup
  # networking.interfaces.eth0.ipv4.addresses = [{
  #   address = "192.168.1.11";
  #   prefixLength = 24;
  # }];
  # networking.defaultGateway = "192.168.1.1";
  # networking.nameservers = [ "192.168.1.1" ];

  # K3s as agent (worker node)
  services.k3s = {
    role = "agent";
    # Server URL and token configured via environment or secrets
    # serverAddr = "https://192.168.1.10:6443";
    # tokenFile = /var/lib/k3s/token;
  };

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
