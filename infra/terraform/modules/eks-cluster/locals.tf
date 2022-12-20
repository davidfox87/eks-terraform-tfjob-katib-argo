locals {
  k8s_service_account_name      = "aws-load-balancer-controller"
  k8s_service_account_namespace = "kube-system"

  k8s_service_account_name_s3access      = "s3-artifact-storage"
  k8s_service_account_namespace_mlflow = "mlflow"
}