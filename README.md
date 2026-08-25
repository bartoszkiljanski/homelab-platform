# Talos homelab platform

Infrastructure as code for a three-node Talos Linux Kubernetes cluster on one
Proxmox VE host. Terraform creates the platform and bootstraps Cilium and Argo
CD; Argo CD owns both releases after handoff.

## Architecture

```text
                         192.168.1.0/24
                  management and Kubernetes LAN
                                  |
                        Proxmox VE 9.2 host
                     vmbr0                 vmbr1
                       |                     |
          +------------+------------+        +--- 10.250.0.0/28
          |            |            |                 |
      talos-cp-01   talos-cp-02   talos-cp-03     Synology NAS
      .201 / .11    .202 / .12    .203 / .13      10.250.0.2
          \____________ Kubernetes ____________/
                         API VIP .200
```

All control-plane nodes are schedulable. Kubernetes uses `vmbr0`; etcd and
storage traffic use `vmbr1`. Control-plane redundancy does not remove the
single Proxmox host as a physical failure domain.

| Component | Version | Managed by |
| --- | --- | --- |
| Proxmox VE | 9.2 | Operator |
| Talos Linux | 1.13.9 | Terraform |
| Kubernetes | 1.36.3 | Talos |
| Cilium | 1.20.1 | Terraform bootstrap, then Argo CD |
| Argo CD | chart 10.4.0 | Terraform bootstrap, then Argo CD |
| CloudNativePG | chart 0.29.0 | Argo CD |
| Authentik | 2026.8.0 | Argo CD |

The `foundation` Terraform root manages the Talos image, NoCloud snippets,
VMs, machine configuration, etcd bootstrap, and generated client files. The
`bootstrap` root installs Cilium and Argo CD and seeds the GitOps root.

## Repository

```text
.
|-- Taskfile.yml
|-- terraform/homelab/
|   |-- foundation/       # Proxmox and Talos
|   `-- bootstrap/        # Cilium, Argo CD, and handoff
`-- k8s/talos/
    |-- gitops/           # Argo CD root objects
    |-- infra/            # Argo-managed releases
    |-- apps/             # Namespaced workloads
    `-- tests/            # disposable validation workloads
```

## Prerequisites

Proxmox must provide:

- node `pve` at `192.168.1.25`;
- bridges `vmbr0` and `vmbr1`;
- storage `local` with `iso,vztmpl,snippets` and `local-zfs`;
- the scoped `homelab-tf@pve!foundation` API token;
- SSH access for uploading snippets.

The workstation needs Task 3.x, Terraform 1.15.x, `talosctl` 1.13.9,
`kubectl` 1.36.x, Git, and optionally k9s.

Set the Proxmox provider variables in the active shell:

```text
PROXMOX_VE_ENDPOINT
PROXMOX_VE_INSECURE
PROXMOX_VE_API_TOKEN
PROXMOX_VE_SSH_USERNAME
PROXMOX_VE_SSH_PASSWORD
```

A private key or SSH agent may replace the password. The Proxmox host must be
present in `~/.ssh/known_hosts`.

Place the private repository's read-only Argo CD deploy key at:

```text
.local/credentials/argocd/homelab-platform-ed25519
```

Create these Bitwarden Secrets Manager entries before enabling Authentik:

```text
AUTHENTIK_SECRET_KEY
AUTHENTIK_BOOTSTRAP_PASSWORD
AUTHENTIK_POSTGRES_PASSWORD
AUTHENTIK_ARGOCD_CLIENT_SECRET
```

Use independent random values. The OIDC client secret is intentionally read by
both the Authentik blueprint and Argo CD.

## Workflow

Review configuration and drift:

```console
task doctor
task validate
task plan
```

Build or reconcile everything:

```console
task up
```

Inspect the platform:

```console
task status
task kubectl -- get nodes -o wide
task talosctl -- health
task k9s
```

Destroy and recreate:

```console
task down CONFIRM=destroy
task up
```

Or run the complete sequence:

```console
task rebuild CONFIRM=rebuild
```

The workflow is ordered, fail-fast, and rerunnable—not transactionally atomic.
After a failure, fix the cause and rerun the same command; Terraform state
records what remains.

## State and security

State and generated administrative material remain ignored under `.local/`.
The current state files are:

```text
.local/terraform-state/prod/foundation/terraform.tfstate
.local/terraform-state/prod/bootstrap/terraform.tfstate
```

Foundation state and Proxmox snippets contain Talos administrative material.
Keep the repository private until a separate public-release audit is complete.
See [SECURITY.md](SECURITY.md).

## Current limitations

- The Proxmox host is a single point of failure.
- Local Terraform state is not an off-device backup.
- Automated etcd recovery and backup coverage beyond platform PostgreSQL are
  not implemented.
