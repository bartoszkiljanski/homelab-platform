resource "helm_release" "cilium" {
  name       = "cilium"
  namespace  = "kube-system"
  repository = "oci://quay.io/cilium/charts"
  chart      = "cilium"
  version    = "1.20.1"

  create_namespace = false
  values           = [file(local.cilium_values_path)]
  wait             = true
  timeout          = 600

  lifecycle {
    ignore_changes = [version, values]
  }
}
