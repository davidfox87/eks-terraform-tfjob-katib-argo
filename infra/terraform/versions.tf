terraform {
  required_version = ">= 1.3.6"
  # A backend defines where Terraform stores its state data files.
  # backend "s3" {
  #   bucket         = "tf-s3-backend-7887"
  #   key            = "state/terraform.tfstate"
  #   region         = "us-west-1"
  #   encrypt        = true
  #   kms_key_id     = "alias/terraform-bucket-key"
  #   dynamodb_table = "terraform-state"
  # }

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



