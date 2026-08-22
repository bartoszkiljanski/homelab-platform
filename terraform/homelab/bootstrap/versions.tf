terraform {
  required_version = "~> 1.15.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.2.0"
    }
  }

  backend "local" {
    path = "../../../.local/terraform-state/prod/bootstrap/terraform.tfstate"
  }
}
