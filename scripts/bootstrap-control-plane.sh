#!/usr/bin/env bash
# Bootstrap script for K3s control plane on NixOS
# Run this after NixOS installation and network configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== K3s Control Plane Bootstrap ==="

# Check if running on NixOS
if [ ! -f /etc/NIXOS ]; then
    echo "Error: This script must be run on NixOS"
    exit 1
fi

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root or with sudo"
    exit 1
fi

# Step 1: Apply NixOS configuration
echo ""
echo "Step 1: Applying NixOS configuration..."
cd "$REPO_DIR/infrastructure/nixos"

# Rebuild NixOS with the flake
nixos-rebuild switch --flake .#control-plane

echo "NixOS configuration applied successfully."

# Step 2: Wait for K3s to start
echo ""
echo "Step 2: Waiting for K3s to start..."
sleep 10

# Wait for K3s to be ready
timeout=120
while [ $timeout -gt 0 ]; do
    if kubectl get nodes &>/dev/null; then
        break
    fi
    echo "Waiting for K3s API server..."
    sleep 5
    timeout=$((timeout - 5))
done

if [ $timeout -le 0 ]; then
    echo "Error: Timeout waiting for K3s to start"
    exit 1
fi

echo "K3s is running!"

# Step 3: Display cluster info
echo ""
echo "Step 3: Cluster information"
kubectl get nodes

# Step 4: Save join token location
echo ""
echo "Step 4: K3s join token"
TOKEN_FILE="/var/lib/rancher/k3s/server/node-token"
if [ -f "$TOKEN_FILE" ]; then
    echo "Join token is stored at: $TOKEN_FILE"
    echo "Use this token when joining worker nodes."
    echo ""
    echo "To join a worker node, you'll need:"
    echo "  Server URL: https://$(hostname):6443"
    echo "  Token: $(cat $TOKEN_FILE)"
else
    echo "Warning: Token file not found at $TOKEN_FILE"
fi

# Step 5: Next steps
echo ""
echo "=== Bootstrap Complete ==="
echo ""
echo "Next steps:"
echo "1. Note the join token above for worker nodes"
echo "2. Flash Raspberry Pi OS on your Pis"
echo "3. Run the Ansible playbook to join workers:"
echo "   cd $REPO_DIR/infrastructure/ansible"
echo "   ansible-playbook -i inventory.yaml site.yaml"
echo ""
