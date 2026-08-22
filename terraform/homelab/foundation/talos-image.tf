locals {
  talos_iso_file_name = format(
    "talos-v%s-nocloud-amd64-%s.iso",
    local.talos_version,
    substr(talos_image_factory_schematic.homelab.id, 0, 12),
  )
}

resource "proxmox_download_file" "talos_nocloud_iso" {
  content_type        = "iso"
  datastore_id        = "local"
  node_name           = local.proxmox_node_name
  url                 = data.talos_image_factory_urls.homelab.urls.iso
  file_name           = local.talos_iso_file_name
  overwrite           = false
  overwrite_unmanaged = false
  upload_timeout      = 600
  verify              = true

  lifecycle {
    precondition {
      condition = (
        startswith(
          data.talos_image_factory_urls.homelab.urls.iso,
          "https://factory.talos.dev/image/${talos_image_factory_schematic.homelab.id}/v${local.talos_version}/",
        ) &&
        endswith(
          data.talos_image_factory_urls.homelab.urls.iso,
          "/nocloud-amd64.iso",
        )
      )
      error_message = "The Talos ISO must be the validated nocloud AMD64 artifact for the active schematic and pinned Talos version."
    }
  }
}
