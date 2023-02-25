# Installs helm chart for the aws-load-balancer-controller.
resource "helm_release" "ingress" {

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"

  namespace = "kube-system"
  set {
    name  = "region"
    value = "us-west-2"
  }
  set {
    name  = "vpcId"
    value =  "${var.vpc_id}"
  }
  set {
    name  = "image.repository"
    value =  "602401143452.dkr.ecr.us-west-2.amazonaws.com/amazon/aws-load-balancer-controller"
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

  depends_on = [
    kubernetes_service_account.eks-service-account
  ]
}



resource "helm_release" "kubernetes_efs_csi_driver" {

  name        = "aws-efs-csi-driver"
  repository  = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
  chart       = "aws-efs-csi-driver"

  namespace = "kube-system"
  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/aws-efs-csi-driver"
  }
  set {
    name  = "controller.serviceAccount.create"
    value = "false"
  }
  set {
    name  = "controller.serviceAccount.name"
    value = local.k8s_service_account_name_efs-csi-driver
  }

  depends_on = [
    kubernetes_service_account.efs-csi-driver-service-account
  ]
}
