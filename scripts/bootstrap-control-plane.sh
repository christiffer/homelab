#!/usr/bin/env bash
# K3s control plane post-setup script
#
# Run this AFTER you've deployed the K3s server via your NixOS config:
#   nixos-rebuild switch --flake /path/to/nixos-config#control-plane
#
# This script:
# - Verifies K3s is running
# - Extracts the join token for worker nodes
# - Displays next steps

set -euo pipefail

echo "=== K3s Control Plane Post-Setup ==="

# Check if running on NixOS
if [ ! -f /etc/NIXOS ]; then
    echo "Warning: Not running on NixOS (continuing anyway)"
fi

# Step 1: Wait for K3s to be ready
echo ""
echo "Step 1: Checking K3s status..."

timeout=60
while [ $timeout -gt 0 ]; do
    if kubectl get nodes &>/dev/null; then
        break
    fi
    echo "Waiting for K3s API server..."
    sleep 5
    timeout=$((timeout - 5))
done

if [ $timeout -le 0 ]; then
    echo "Error: K3s is not running or not accessible"
    echo ""
    echo "Ensure you've deployed your NixOS config with the k3s-server module:"
    echo "  nixos-rebuild switch --flake /path/to/your-nixos-config#control-plane"
    exit 1
fi

echo "K3s is running!"
kubectl get nodes

# Step 2: Extract join token
echo ""
echo "Step 2: K3s join token"
TOKEN_FILE="/var/lib/rancher/k3s/server/node-token"

if [ -f "$TOKEN_FILE" ]; then
    SERVER_URL="https://$(hostname):6443"
    TOKEN=$(cat "$TOKEN_FILE")

    echo ""
    echo "Worker nodes need these values:"
    echo "  Server URL: $SERVER_URL"
    echo "  Token file: $TOKEN_FILE"
    echo ""
    echo "Token value (for manual setup):"
    echo "  $TOKEN"
    echo ""
    echo "In your worker's NixOS config, add:"
    echo "  services.k3s.serverAddr = \"$SERVER_URL\";"
    echo "  services.k3s.tokenFile = /path/to/token;  # Copy token to this file"
else
    echo "Error: Token file not found at $TOKEN_FILE"
    echo "K3s may not have started correctly."
    exit 1
fi

# Step 3: Next steps
echo ""
echo "=== Next Steps ==="
echo ""
echo "For NixOS worker nodes (x86):"
echo "  1. Copy the token to the worker machine"
echo "  2. Import k3s-agent module from this repo in your NixOS config"
echo "  3. Set services.k3s.serverAddr and services.k3s.tokenFile"
echo "  4. Run: nixos-rebuild switch --flake .#worker-hostname"
echo ""
echo "For Raspberry Pi workers:"
echo "  1. Update infrastructure/ansible/group_vars/all.yaml with the token"
echo "  2. Run: ./scripts/join-worker.sh"
echo ""
