# Home Lab K3s NixOS Modules

This directory provides K3s NixOS modules that can be imported into your existing NixOS configuration.

## Structure

```
modules/k3s/
├── base.nix    # Shared: kernel modules, sysctl, packages
├── server.nix  # Control plane: server role, etcd ports (imports base)
└── agent.nix   # Worker node: agent role (imports base)
```

## Usage

### 1. Add this flake as an input to your NixOS configuration

```nix
# flake.nix in your NixOS config repo
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    # Add home-lab modules
    home-lab.url = "github:christiffer/homelab?dir=infrastructure/nixos";
    # Or for local development:
    # home-lab.url = "path:/home/chris/code/christiffer/homelab?dir=infrastructure/nixos";
  };

  outputs = { self, nixpkgs, home-lab, ... }: {
    nixosConfigurations = {
      control-plane = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/control-plane/configuration.nix
          home-lab.nixosModules.k3s-server
        ];
      };

      nuc-worker-1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/nuc-worker-1/configuration.nix
          home-lab.nixosModules.k3s-agent
        ];
      };
    };
  };
}
```

### 2. Configure your host

**Control plane (`hosts/control-plane/configuration.nix`):**

```nix
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "control-plane";

  # K3s server is configured by the module, but you can override:
  # services.k3s.extraFlags = toString [ "--disable=traefik" "--tls-san=myhost.local" ];
}
```

**Worker node (`hosts/nuc-worker-1/configuration.nix`):**

```nix
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nuc-worker-1";

  # Required: tell agent where to find the server and how to authenticate.
  # The token file must already exist on disk (see "K3s Token Management" below).
  services.k3s.serverAddr = "https://<control-plane-ip>:6443";
  services.k3s.tokenFile = /var/lib/k3s/token;
}
```

## Available Modules

| Module | Description |
|--------|-------------|
| `k3s-base` | Shared config only (kernel modules, sysctl, kubectl) |
| `k3s-server` | Control plane - includes base + server role + etcd ports |
| `k3s-agent` | Worker node - includes base + agent role |

## K3s Token Management

Workers need the server join token to authenticate with the control plane.

### Current approach: manual copy

1. On the control plane, read the token:

   ```bash
   sudo cat /var/lib/rancher/k3s/server/node-token
   ```

2. On each worker node, write the token to a file:

   ```bash
   sudo mkdir -p /var/lib/k3s
   sudo tee /var/lib/k3s/token > /dev/null <<< 'K10...<your-token>'
   sudo chmod 600 /var/lib/k3s/token
   ```

3. In the worker's NixOS host configuration, reference the file:

   ```nix
   services.k3s.serverAddr = "https://<control-plane-ip>:6443";
   services.k3s.tokenFile = /var/lib/k3s/token;
   ```

4. Rebuild the worker:

   ```bash
   sudo nixos-rebuild switch
   ```

5. Verify the node joined from the control plane:

   ```bash
   kubectl get nodes
   ```

### Future: encrypted secrets

When secrets management is set up (SOPS + age), the token can be committed
encrypted to the repo and decrypted at deploy time, removing the manual copy
step. This is tracked as a future improvement.

## Development

When iterating on these modules locally, use a path input:

```nix
home-lab.url = "path:/home/chris/code/christiffer/homelab?dir=infrastructure/nixos";
```

Then update the lock file after changes:

```bash
nix flake lock --update-input home-lab
```
