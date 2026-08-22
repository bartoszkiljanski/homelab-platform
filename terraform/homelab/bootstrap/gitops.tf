resource "terraform_data" "gitops_root" {
  depends_on = [helm_release.argocd]

  triggers_replace = [
    for manifest_path in local.gitops_manifest_paths : filesha256(manifest_path)
  ]

  provisioner "local-exec" {
    working_dir = local.repository_root
    environment = {
      KUBECONFIG = local.kubeconfig_path
    }

    command = format(
      "kubectl apply --server-side --field-manager=terraform-bootstrap %s",
      join(" ", [
        for manifest_path in local.gitops_manifest_relative_paths : "-f ${manifest_path}"
      ])
    )
  }
}
