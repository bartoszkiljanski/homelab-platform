locals {
  # iscsi-tools is included for future Synology iSCSI use. Its compatibility
  # with the selected CSI driver must be revalidated before enabling iSCSI.
  talos_image_factory_extensions = [
    "siderolabs/iscsi-tools",
    "siderolabs/qemu-guest-agent",
  ]
}

data "talos_image_factory_extensions_versions" "relevant" {
  talos_version = "v${local.talos_version}"

  exact_filters = {
    names = local.talos_image_factory_extensions
  }
}

resource "talos_image_factory_schematic" "homelab" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = local.talos_image_factory_extensions
      }
    }
  })

  lifecycle {
    precondition {
      condition = (
        toset(data.talos_image_factory_extensions_versions.relevant.extensions_info[*].name) ==
        toset(local.talos_image_factory_extensions)
      )
      error_message = "Every selected Talos system extension must be available for the pinned Talos version."
    }
  }
}

data "talos_image_factory_urls" "homelab" {
  talos_version = "v${local.talos_version}"
  schematic_id  = talos_image_factory_schematic.homelab.id
  architecture  = "amd64"
  platform      = "nocloud"
}
