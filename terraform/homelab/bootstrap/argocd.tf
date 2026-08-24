resource "helm_release" "argocd" {
  depends_on = [helm_release.cilium]

  name       = "argocd"
  namespace  = "argocd"
  repository = "oci://ghcr.io/argoproj/argo-helm"
  chart      = "argo-cd"
  version    = "10.4.0"

  create_namespace = true
  values           = [file(local.argocd_values_path)]
  wait             = true
  wait_for_jobs    = true
  timeout          = 600

  lifecycle {
    ignore_changes = all
  }
}
