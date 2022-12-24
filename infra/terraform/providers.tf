provider "aws" {
  region = "us-west-1"
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.my-eks.cluster_id
}

provider "kubernetes" {
  host                   = module.my-eks.cluster_endpoint
  cluster_ca_certificate = "${base64decode(module.my-eks.kubeconfig-certificate-authority-data)}"
  #token                  = data.aws_eks_cluster_auth.cluster.token
  # Token workaround
  exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster-name]
      command     = "aws"
  }
}