terraform {
  required_version = "~> 1.15.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.9.0"
    }

    proxmox = {
      source  = "bpg/proxmox"
      version = "0.111.1"
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
