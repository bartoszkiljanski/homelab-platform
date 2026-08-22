resource "proxmox_virtual_environment_file" "talos_machine_configuration" {
  for_each = data.talos_machine_configuration.control_plane

  content_type = "snippets"
  datastore_id = "local"
  node_name    = local.proxmox_node_name
  overwrite    = true

  source_raw {
    data      = each.value.machine_configuration
    file_name = "${each.key}.yaml"
  }
}

resource "talos_machine_bootstrap" "homelab" {
  depends_on = [proxmox_virtual_environment_vm.talos_control_plane]

  node                 = local.talos_node_specs["talos-cp-01"].lan_ip
  endpoint             = local.talos_node_specs["talos-cp-01"].lan_ip
  client_configuration = talos_machine_secrets.homelab.client_configuration

  timeouts = {
    create = "15m"
  }
}

resource "talos_cluster_kubeconfig" "homelab" {
  depends_on = [talos_machine_bootstrap.homelab]

  node                 = local.talos_node_specs["talos-cp-01"].lan_ip
  endpoint             = local.talos_node_specs["talos-cp-01"].lan_ip
  client_configuration = talos_machine_secrets.homelab.client_configuration

  timeouts = {
    create = "10m"
    update = "10m"
  }
}

resource "local_sensitive_file" "kubeconfig" {
  content              = talos_cluster_kubeconfig.homelab.kubeconfig_raw
  filename             = "${local.generated_directory}/kubeconfig"
  file_permission      = "0600"
  directory_permission = "0700"
}
