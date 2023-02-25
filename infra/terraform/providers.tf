provider "aws" {
  profile = "default"
  region = "us-west-2"

  # tags all resources provisioned by this project
  default_tags {
    tags = {
      Environment               = "dev"
      mlops-platform            = "k8s-argo-kubeflow"
    }
  }
}

#we should use a data block to get the most up-to-date cluster creds
data "aws_eks_cluster" "cluster" {
  name = module.my-eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.my-eks.cluster_id
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)}"

  exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster-name]
      command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", var.cluster-name]
    }
  }
}


# for local testing
# provider "kubernetes" {
#   config_path    = "~/.kube/config"
#   config_context = "minikube"
# }

# provider "helm" {
#  kubernetes {
#   config_path    = "~/.kube/config"
#   config_context = "minikube"
#  }
# }
