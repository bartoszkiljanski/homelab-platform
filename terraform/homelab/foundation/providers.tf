provider "proxmox" {
  ssh {
    node {
      name    = local.proxmox_node_name
      address = local.proxmox_node_ip
    }
  }
}
