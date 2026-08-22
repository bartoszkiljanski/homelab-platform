resource "proxmox_virtual_environment_vm" "talos_control_plane" {
  for_each = local.talos_node_specs

  name        = each.key
  description = "Schedulable Talos control-plane node managed by Terraform."
  tags        = ["control-plane", "homelab", "talos", "terraform"]

  node_name = local.proxmox_node_name
  vm_id     = each.value.vm_id

  started             = true
  on_boot             = true
  reboot_after_update = false
  stop_on_destroy     = true

  bios          = "seabios"
  machine       = "q35"
  scsi_hardware = "virtio-scsi-single"
  boot_order    = ["scsi0", "ide2"]
  tablet_device = false

  agent {
    enabled = true
    trim    = true

    wait_for_ip {
      disabled = true
    }
  }

  cpu {
    cores   = each.value.cpu_cores
    sockets = 1
    type    = "host"
  }

  memory {
    dedicated = each.value.memory_mb
    floating  = 0
  }

  initialization {
    datastore_id      = "local-zfs"
    interface         = "ide0"
    type              = "nocloud"
    user_data_file_id = proxmox_virtual_environment_file.talos_machine_configuration[each.key].id
  }

  cdrom {
    file_id   = proxmox_download_file.talos_nocloud_iso.id
    interface = "ide2"
  }

  disk {
    aio          = "io_uring"
    backup       = true
    cache        = "none"
    datastore_id = "local-zfs"
    discard      = "on"
    interface    = "scsi0"
    iothread     = true
    replicate    = false
    size         = each.value.system_disk_gb
    ssd          = true
  }

  network_device {
    bridge   = local.lan.bridge
    firewall = false
    model    = "virtio"
    mtu      = 1500
  }

  network_device {
    bridge   = local.storage_network.bridge
    firewall = false
    model    = "virtio"
    mtu      = 1500
  }

  operating_system {
    type = "l26"
  }

  serial_device {
    device = "socket"
  }

  vga {
    type = "serial0"
  }
}
