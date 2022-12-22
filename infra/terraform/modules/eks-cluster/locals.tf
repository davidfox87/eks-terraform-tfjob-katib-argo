locals {
  k8s_service_account_name      = "aws-load-balancer-controller"
  k8s_service_account_namespace = "kube-system"

  k8s_service_account_name_s3access      = "s3-artifact-storage"
  k8s_service_account_namespace_mlflow = "mlflow"

  k8s_service_account_name_efs-csi-driver      = "efs-csi-controller-sa"
  k8s_service_account_namespace_efs-csi-driver = "kube-system"
}