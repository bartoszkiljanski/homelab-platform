terraform {
  required_version = "~> 1.16.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.9.1"
    }

    proxmox = {
      source  = "bpg/proxmox"
      version = "0.113.1"
    }

    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
    }
  }

  backend "s3" {
    key          = "prod/foundation/terraform.tfstate"
    use_lockfile = false
  }
}
