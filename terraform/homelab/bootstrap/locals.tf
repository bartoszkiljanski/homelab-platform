locals {
  repository_root    = abspath("${path.module}/../../..")
  argocd_values_path = "${local.repository_root}/k8s/talos/infra/argocd/values.yaml"
  cilium_values_path = "${local.repository_root}/k8s/talos/infra/cilium/values.yaml"
  gitops_manifest_relative_paths = [
    "k8s/talos/gitops/infra-project.yaml",
    "k8s/talos/gitops/infra-applicationset.yaml",
    "k8s/talos/gitops/root.yaml",
  ]
  gitops_manifest_paths = [
    for manifest_path in local.gitops_manifest_relative_paths :
    "${local.repository_root}/${manifest_path}"
  ]
  kubeconfig_path = "${local.repository_root}/.local/generated/prod/talos/kubeconfig"
}
