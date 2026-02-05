# Home Lab Infrastructure

A home lab infrastructure using K3s + ArgoCD for container orchestration, with hybrid configuration management (NixOS on x86, Ansible on Raspberry Pis).

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        GitOps Flow                          │
│  GitHub Repo ──▶ ArgoCD ──▶ K3s Cluster ──▶ Services       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                      K3s Cluster                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │ x86 Server  │  │   Pi 5      │  │   Pi 4s     │         │
│  │ (control +  │  │  (worker)   │  │  (workers)  │         │
│  │   worker)   │  │             │  │             │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                   Support Services                          │
│  Pi 1/2/3: PiHole DNS, monitoring exporters, backup agents │
└─────────────────────────────────────────────────────────────┘
```

## Hardware Inventory

| Device | Role | OS |
|--------|------|-----|
| x86 Server | K3s control plane + heavy workloads | NixOS |
| Pi 5 | K3s worker (ARM workloads) | Raspberry Pi OS |
| Pi 4 (x2) | K3s workers | Raspberry Pi OS |
| Pi 1/2/3 | Support services (DNS, monitoring) | Raspberry Pi OS |

## Repository Structure

```
home_assistant/
├── tasks/                      # Task tracking (YAML-based)
├── infrastructure/
│   ├── nixos/                 # NixOS configurations (x86)
│   └── ansible/               # Ansible playbooks (Pis)
├── kubernetes/
│   ├── apps/                  # Application deployments
│   ├── infrastructure/        # Cluster infrastructure
│   └── argocd-apps/           # ArgoCD Application CRDs
└── scripts/                   # Bootstrap and utility scripts
```

## Getting Started

### Task Tracking

Tasks are tracked in YAML files under `tasks/`:
- `schema.yaml` - Task structure definition
- `backlog.yaml` - Pending tasks
- `in-progress.yaml` - Active work
- `completed/` - Archived completed tasks

### Implementation Phases

1. **Phase 1: Control Plane** - NixOS + K3s on x86 server
2. **Phase 2: Worker Nodes** - Ansible + K3s agents on Pis
3. **Phase 3: GitOps** - ArgoCD deployment and configuration
4. **Phase 4: Core Services** - Ingress, certs, storage, monitoring
5. **Phase 5: Applications** - Home Assistant, Vikunja, etc.

## Key Technologies

- **Orchestration**: K3s (lightweight Kubernetes)
- **GitOps**: ArgoCD
- **x86 Config**: NixOS (declarative, reproducible)
- **Pi Config**: Ansible
- **Storage**: Longhorn (distributed)
- **Secrets**: SOPS + age
- **Remote Access**: Tailscale
