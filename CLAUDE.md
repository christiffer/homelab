# CLAUDE.md — Home Lab Infrastructure

## Project overview

K3s + ArgoCD home lab with hybrid config management: NixOS (x86 server), Ansible (Raspberry Pis). GitOps-driven Kubernetes deployments.

## Repository layout

- `infrastructure/nixos/` — NixOS flake exporting K3s modules (imported by external host config repo)
- `infrastructure/ansible/` — Ansible playbooks and roles for Raspberry Pis
- `kubernetes/` — K8s manifests: `apps/`, `infrastructure/`, `argocd-apps/`
- `scripts/` — Bootstrap and worker join scripts
- `tasks/` — YAML-based task tracking (schema, backlog, in-progress, completed/)

## Task tracking

Tasks live in `tasks/` as YAML files following `tasks/schema.yaml`. IDs use `prefix-nnn` format (hw-001, sw-001). Tasks have types (software/hardware/hybrid) and assignees (claude/human). Check `tasks/backlog.yaml` and `tasks/in-progress.yaml` before starting work.

## Key conventions

- NixOS modules are **flake outputs** consumed by an external NixOS config repo — don't add host-specific config here
- Kubernetes manifests use kustomize where applicable
- ArgoCD follows the app-of-apps pattern (`argocd-apps/root-app.yaml`)
- K3s uses ingress-nginx (Traefik disabled), Longhorn for storage, cert-manager for TLS
- Secrets: SOPS + age (planned)

## Working with this repo

- **NixOS changes**: Edit modules in `infrastructure/nixos/modules/`, test with `nix flake check`
- **Ansible changes**: Edit roles/playbooks in `infrastructure/ansible/`, test with `--check` mode
- **K8s manifests**: Add to appropriate dir under `kubernetes/`, ArgoCD syncs from git
- **Task updates**: Move tasks between `backlog.yaml` → `in-progress.yaml` → `completed/YYYY-MM.yaml`

## Do not

- Add host-specific NixOS configurations (those belong in the external config repo)
- Commit secrets or tokens — use SOPS/age or placeholder references
- Skip task tracking — update task YAML files when starting or completing work
