# Repository Guidelines

## Project Structure & Module Organization

`terraform/homelab/foundation/` manages Proxmox VMs and Talos; `bootstrap/` installs Cilium and Argo CD. Under `k8s/talos/`, `gitops/` orchestrates Argo CD, `infra/` holds platform components, and `tests/` holds disposable checks. Use `Taskfile.yml` as the operator interface. Keep generated state and credentials only under ignored `.local/` paths.

## GitOps Deployment Model

Bootstrap applies the GitOps manifests, including Argo CD's root `Application`. The root tracks `main` at `k8s/talos/gitops/` and manages two projects and `ApplicationSet`s. `infra` discovers every `k8s/talos/infra/*` directory; the basename becomes the Argo application and namespace, except Cilium and Metrics Server target `kube-system`. `apps` similarly discovers `k8s/talos/apps/*` and deploys each workload into its same-named namespace; it generates nothing until app directories exist. Each component needs a `kustomization.yaml`. Argo CD runs Kustomize, combining manifests or nested bases and rendering `helmCharts` with `values.yaml`. Both sets create namespaces and automatically prune and self-heal, so merges to `main` can change live cluster state.

## Commit & Pull Request Guidelines

Use Conventional Commit subjects such as `feat:`, `fix:`, `chore:`, or `fix(network):`; keep them lowercase, imperative, and focused. Pull requests must explain operational impact, link relevant issues, list validation, and summarize plans or health checks. Highlight destructive, networking, storage, certificate, and secret changes.

## Security & Configuration

Follow `SECURITY.md`. Never commit state, plans, kubeconfigs, Talos secrets, keys, credentials, real variable files, or private infrastructure identifiers. Review `git status --short`, `git diff --check`, and staged and unstaged diffs; redact sensitive PR evidence.
