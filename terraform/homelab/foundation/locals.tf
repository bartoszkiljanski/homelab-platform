locals {
  cluster_name      = "homelab"
  proxmox_node_name = "pve"
  proxmox_node_ip   = "192.168.1.25"

  talos_version      = "1.13.9"
  kubernetes_version = "1.36.3"

  lan = {
    bridge        = "vmbr0"
    cidr          = "192.168.1.0/24"
    gateway       = "192.168.1.1"
    prefix_length = 24
    dns_servers   = ["192.168.1.1"]
    api_vip       = "192.168.1.200"
  }

  storage_network = {
    bridge        = "vmbr1"
    cidr          = "10.250.0.0/28"
    prefix_length = 28
  }

  pod_cidr     = "10.244.0.0/16"
  service_cidr = "10.96.0.0/12"

  generated_directory = abspath("${path.module}/../../../.local/generated/prod/talos")

  talos_node_specs = {
    talos-cp-01 = {
      vm_id          = 201
      lan_ip         = "192.168.1.201"
      storage_ip     = "10.250.0.11"
      cpu_cores      = 4
      memory_mb      = 6144
      system_disk_gb = 64
    }

    talos-cp-02 = {
      vm_id          = 202
      lan_ip         = "192.168.1.202"
      storage_ip     = "10.250.0.12"
      cpu_cores      = 4
      memory_mb      = 6144
      system_disk_gb = 64
    }

    talos-cp-03 = {
      vm_id          = 203
      lan_ip         = "192.168.1.203"
      storage_ip     = "10.250.0.13"
      cpu_cores      = 4
      memory_mb      = 6144
      system_disk_gb = 64
    }
  }

  desired_vm_ids = toset([
    for node in values(local.talos_node_specs) : node.vm_id
  ])

  all_lan_ips = [
    for node in values(local.talos_node_specs) : node.lan_ip
  ]

  all_storage_ips = [
    for node in values(local.talos_node_specs) : node.storage_ip
  ]
}
