terraform {
  required_version = "~> 1.16.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
  }

  backend "s3" {
    key          = "prod/bootstrap/terraform.tfstate"
    use_lockfile = false
  }
}
