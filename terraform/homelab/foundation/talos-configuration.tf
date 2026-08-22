resource "talos_machine_secrets" "homelab" {
  talos_version = local.talos_version
}

data "talos_client_configuration" "homelab" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.homelab.client_configuration
  endpoints            = local.all_lan_ips
  nodes                = local.all_lan_ips
}

data "talos_machine_configuration" "control_plane" {
  for_each = local.talos_node_specs

  cluster_endpoint = "https://${local.lan.api_vip}:6443"
  cluster_name     = local.cluster_name
  config_patches = [
    local.talos_common_patch,
    local.talos_node_network_patches[each.key],
    local.talos_node_hostname_patches[each.key],
  ]
  kubernetes_version = local.kubernetes_version
  machine_secrets    = talos_machine_secrets.homelab.machine_secrets
  machine_type       = "controlplane"
  talos_version      = local.talos_version
}

locals {
  talos_common_patch = yamlencode({
    machine = {
      install = {
        disk  = "/dev/sda"
        image = data.talos_image_factory_urls.homelab.urls.installer
      }

      kubelet = {
        nodeIP = {
          validSubnets = [local.lan.cidr]
        }
      }
    }

    cluster = {
      allowSchedulingOnControlPlanes = true

      etcd = {
        advertisedSubnets = [local.storage_network.cidr]
      }

      proxy = {
        disabled = true
      }

      network = {
        cni = {
          name = "none"
        }

        podSubnets     = [local.pod_cidr]
        serviceSubnets = [local.service_cidr]
      }
    }
  })

  talos_node_network_patches = {
    for name, node in local.talos_node_specs : name => yamlencode({
      machine = {
        network = {
          nameservers = local.lan.dns_servers

          interfaces = [
            {
              interface = "eth0"
              addresses = ["${node.lan_ip}/${local.lan.prefix_length}"]
              dhcp      = false
              mtu       = 1500
              routes = [
                {
                  network = "0.0.0.0/0"
                  gateway = local.lan.gateway
                }
              ]
              vip = {
                ip = local.lan.api_vip
              }
            },
            {
              interface = "eth1"
              addresses = ["${node.storage_ip}/${local.storage_network.prefix_length}"]
              dhcp      = false
              mtu       = 1500
            },
          ]
        }
      }
    })
  }

  talos_node_hostname_patches = {
    for name, node in local.talos_node_specs : name => yamlencode({
      apiVersion = "v1alpha1"
      kind       = "HostnameConfig"
      auto = {
        "$patch" = "delete"
      }
      hostname = name
    })
  }
}

resource "local_sensitive_file" "talosconfig" {
  content              = data.talos_client_configuration.homelab.talos_config
  filename             = "${local.generated_directory}/talosconfig"
  file_permission      = "0600"
  directory_permission = "0700"
}

resource "local_sensitive_file" "machine_configuration" {
  for_each = data.talos_machine_configuration.control_plane

  content              = each.value.machine_configuration
  filename             = "${local.generated_directory}/${each.key}.yaml"
  file_permission      = "0600"
  directory_permission = "0700"
}
