#!/usr/bin/env bash
# Join worker nodes to the K3s cluster using Ansible
# Run this from a machine with Ansible and SSH access to the Pis

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
ANSIBLE_DIR="$REPO_DIR/infrastructure/ansible"

echo "=== K3s Worker Node Join Script ==="

# Check for required tools
if ! command -v ansible-playbook &>/dev/null; then
    echo "Error: ansible-playbook not found. Install Ansible first."
    exit 1
fi

# Parse arguments
LIMIT=""
TAGS=""
CHECK_MODE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --limit|-l)
            LIMIT="--limit $2"
            shift 2
            ;;
        --tags|-t)
            TAGS="--tags $2"
            shift 2
            ;;
        --check)
            CHECK_MODE="--check"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --limit, -l HOST    Limit to specific host(s)"
            echo "  --tags, -t TAGS     Run only specific tags"
            echo "  --check             Dry-run mode"
            echo "  --help, -h          Show this help"
            echo ""
            echo "Examples:"
            echo "  $0                              # Configure all workers"
            echo "  $0 --limit pi5-worker           # Configure only pi5-worker"
            echo "  $0 --check                      # Dry-run on all workers"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Check if K3s token is configured
echo ""
echo "Checking configuration..."

cd "$ANSIBLE_DIR"

# Verify inventory exists
if [ ! -f inventory.yaml ]; then
    echo "Error: inventory.yaml not found in $ANSIBLE_DIR"
    exit 1
fi

# Prompt for K3s token if not set
if ! grep -q "k3s_token:" group_vars/all.yaml 2>/dev/null; then
    echo ""
    echo "K3s token not found in group_vars/all.yaml"
    echo "Get the token from your control plane:"
    echo "  ssh control-plane 'sudo cat /var/lib/rancher/k3s/server/node-token'"
    echo ""
    read -rp "Enter K3s token (or press Enter to skip): " TOKEN

    if [ -n "$TOKEN" ]; then
        echo "k3s_token: \"$TOKEN\"" >> group_vars/all.yaml
        echo "Token added to group_vars/all.yaml"
    else
        echo "Warning: Continuing without token. K3s agent installation will be skipped."
    fi
fi

# Run Ansible playbook
echo ""
echo "Running Ansible playbook..."
echo "Command: ansible-playbook -i inventory.yaml site.yaml $LIMIT $TAGS $CHECK_MODE"
echo ""

# shellcheck disable=SC2086
ansible-playbook -i inventory.yaml site.yaml $LIMIT $TAGS $CHECK_MODE

echo ""
echo "=== Worker Node Configuration Complete ==="
echo ""
echo "Check cluster status with:"
echo "  kubectl get nodes"
