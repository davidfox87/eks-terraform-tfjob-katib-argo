provider "aws" {
  profile = "default"
  region = "us-west-1"

  default_tags {
    tags = {
      Environment               = "dev"
      mlops-platform            = "k8s-argo-kubeflow"
    }
  }
}

# provider "kubernetes" {
#   host                   = module.my-eks.cluster_endpoint
#   cluster_ca_certificate = "${base64decode(module.my-eks.kubeconfig-certificate-authority-data)}"

#   exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       args        = ["eks", "get-token", "--cluster-name", var.cluster-name]
#       command     = "aws"
#   }
# }

# provider "helm" {
#   kubernetes {
#     host                   = module.my-eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.my-eks.kubeconfig-certificate-authority-data)

#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "aws"
#       # This requires the awscli to be installed locally where Terraform is executed
#       args = ["eks", "get-token", "--cluster-name", var.cluster-name]
#     }
#   }
# }


provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

provider "helm" {
 kubernetes {
  config_path    = "~/.kube/config"
  config_context = "minikube"
 }
}
# provider "helm" {
#   kubernetes {
#     host                   = module.my-eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.my-eks.kubeconfig-certificate-authority-data)

#   }
# }