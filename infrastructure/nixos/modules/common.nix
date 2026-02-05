# Common NixOS configuration shared across all hosts
{ config, pkgs, ... }:

{
  # System basics
  time.timeZone = "UTC";  # TODO: Set to your timezone
  i18n.defaultLocale = "en_US.UTF-8";

  # Essential packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    tmux
    jq
    yq
  ];

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Firewall - base rules (K3s module adds its own)
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # Enable nix flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # System state version - don't change after initial setup
  system.stateVersion = "24.05";
}
