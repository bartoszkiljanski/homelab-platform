check "unique_vm_ids" {
  assert {
    condition     = length(local.desired_vm_ids) == length(local.talos_node_specs)
    error_message = "Each Talos node must have a unique Proxmox VMID."
  }
}

check "unique_lan_addresses" {
  assert {
    condition     = length(distinct(local.all_lan_ips)) == length(local.talos_node_specs)
    error_message = "Each Talos node must have a unique LAN address."
  }
}

check "unique_storage_addresses" {
  assert {
    condition     = length(distinct(local.all_storage_ips)) == length(local.talos_node_specs)
    error_message = "Each Talos node must have a unique storage address."
  }
}
