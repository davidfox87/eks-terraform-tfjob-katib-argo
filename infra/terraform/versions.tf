terraform {
  required_version = ">= 0.12.6"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "= 2.5.1"
    }

    aws = {
      source = "hashicorp/aws"
      version = ">= 3.27"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.4"
    }

  }

}