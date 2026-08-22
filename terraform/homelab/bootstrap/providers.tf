provider "helm" {
  kubernetes = {
    config_path = local.kubeconfig_path
  }
}
