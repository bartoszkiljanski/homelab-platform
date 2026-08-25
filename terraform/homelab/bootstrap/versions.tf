terraform {
  required_version = "~> 1.15.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.2.0"
    }
  }

  backend "s3" {
    key          = "prod/bootstrap/terraform.tfstate"
    use_lockfile = false
  }
}
