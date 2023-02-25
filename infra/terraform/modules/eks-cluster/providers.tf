data "aws_eks_cluster" "example" {
  name = aws_eks_cluster.demo.id
}
data "aws_eks_cluster_auth" "example" {
  name = aws_eks_cluster.demo.id
}
data "tls_certificate" "cluster_oidc_issuer_url" {
  url = aws_eks_cluster.demo.identity[0].oidc[0].issuer
}

provider "helm" {
    kubernetes {
    host                   = data.aws_eks_cluster.example.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.example.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster-name]
      command     = "aws"
    }
  }
}


