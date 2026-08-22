# Security policy

## Repository publication

Keep the operational repository private. If it is made public later, publish
an audited working tree through a newly initialized repository rather than
reusing the current Git history.

Never automate repository visibility changes as part of platform deployment.

## Never commit

- Terraform state, saved plans, backend credentials, or real variable files;
- Talos secrets, machine configuration, `talosconfig`, or kubeconfig;
- etcd snapshots, backup credentials, or recovery material;
- Proxmox, Synology, GitHub, Backblaze, or password-manager credentials;
- Kubernetes Secret values or Argo CD repository private keys;
- private keys, generated certificates, environment files, or transcripts;
- physical or virtual MAC addresses.

`.gitignore` is a guardrail, not a security boundary.

## Trust boundaries

Argo CD can manage cluster-scoped resources from the private repository's
`main` branch. Protect that branch, require multi-factor authentication, limit
write access, and use a read-only deploy key for reconciliation.

Foundation state and Proxmox NoCloud snippets contain Talos administrative
material. Keep them on encrypted storage and never publish them as build or CI
artifacts. The Proxmox API token belongs only in the active process environment.

## Review before publishing

Before any commit or push, inspect at least:

```console
git status --short
git diff --check
git diff
git diff --cached
```

Before creating a public repository, also scan the complete candidate tree for
secrets, credentials, MAC addresses, generated Talos material, Terraform state,
and private infrastructure metadata.

If exposure is suspected, revoke the credential, inspect the full history and
remote caches, and rebuild the public history from an audited working tree.
