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

# The Terraform Helm provider contains the helm_release resource that deploys 
# a Helm chart to a Kubernetes cluster. The helm_release resource specifies the
# chart name and the configuration variables for your deployment.

# Installs helm chart for the aws-load-balancer-controller.
resource "helm_release" "ingress" {

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace = "kube-system"
  set {
    name  = "region"
    value = "us-west-1"
  }
  set {
    name  = "vpcId"
    value =  "${var.vpc_id}"
  }
  set {
    name  = "image.repository"
    value =  "602401143452.dkr.ecr.us-west-1.amazonaws.com/amazon/aws-load-balancer-controller"
  }
  set {
    name  = "clusterName"
    value =  "${var.cluster-name}"
  }
  set {
    name  = "serviceAccount.create"
    value =  "false"
  }

  set {
    name  = "serviceAccount.name"
    value =  "aws-load-balancer-controller"
  }
}



resource "helm_release" "kubernetes_efs_csi_driver" {

  name        = "aws-efs-csi-driver"
  repository  = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart       = "aws-efs-csi-driver"
  version     = 1.2

  namespace = "kube-system"
  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.us-west-1.amazonaws.com/eks/aws-efs-csi-driver"
  }
  set {
    name  = "controller.serviceAccount.create"
    value = "true"
  }
  set {
    name  = "controller.serviceAccount.name"
    value = local.k8s_service_account_name_efs-csi-driver
  }
  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.iam_assumable_role_efs_access.iam_role_arn
  }

}
