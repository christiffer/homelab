#!/usr/bin/env bash
# Bootstrap ArgoCD on the K3s cluster
#
# Run this from the repo root on a machine with kubectl access to the cluster:
#   ./scripts/bootstrap-argocd.sh
#
# This script:
# - Installs ArgoCD via kustomize
# - Waits for ArgoCD to be ready
# - Retrieves the initial admin password
# - Applies the root app-of-apps

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== ArgoCD Bootstrap ==="

# Step 1: Check kubectl access
echo ""
echo "Step 1: Checking cluster access..."
if ! kubectl get nodes &>/dev/null; then
    echo "Error: Cannot connect to Kubernetes cluster"
    echo "Ensure KUBECONFIG is set or ~/.kube/config is configured"
    exit 1
fi
echo "Cluster accessible:"
kubectl get nodes

# Step 2: Install ArgoCD
echo ""
echo "Step 2: Installing ArgoCD..."
kubectl apply -k "$REPO_ROOT/kubernetes/infrastructure/argocd/"

# Step 3: Wait for ArgoCD to be ready
echo ""
echo "Step 3: Waiting for ArgoCD to be ready..."
kubectl -n argocd rollout status deployment/argocd-server --timeout=300s
echo "ArgoCD is running!"

# Step 4: Get initial admin password
echo ""
echo "Step 4: Initial admin credentials"
echo "  Username: admin"

RETRIES=10
while [ $RETRIES -gt 0 ]; do
    PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d 2>/dev/null) || true
    if [ -n "${PASSWORD:-}" ]; then
        echo "  Password: $PASSWORD"
        break
    fi
    echo "  Waiting for admin secret..."
    sleep 5
    RETRIES=$((RETRIES - 1))
done

if [ -z "${PASSWORD:-}" ]; then
    echo "  Warning: Could not retrieve admin password yet"
    echo "  Try: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
fi

# Step 5: Apply root application (app-of-apps)
echo ""
echo "Step 5: Applying root application (app-of-apps)..."
kubectl apply -f "$REPO_ROOT/kubernetes/argocd-apps/root-app.yaml"

# Step 6: Access info
echo ""
echo "=== ArgoCD is ready ==="
echo ""
echo "Access the UI via port-forward:"
echo "  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  Then open: http://localhost:8080"
echo ""
echo "Or via the ArgoCD CLI:"
echo "  argocd login localhost:8080 --username admin --password $PASSWORD --insecure"
echo ""
echo "Change the admin password after first login:"
echo "  argocd account update-password"
echo ""
