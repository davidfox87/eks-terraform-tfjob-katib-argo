# pass in from top-level dir
# provider "kubernetes" {
#   host = "https://cluster_endpoint:port"

#   client_certificate     = file("~/.kube/client-cert.pem")
#   client_key             = file("~/.kube/client-key.pem")
#   cluster_ca_certificate = file("~/.kube/cluster-ca-cert.pem")
# }

resource "kubernetes_manifest" "storage_class" {
  manifest = {
    "apiVersion" = "storage.k8s.io/v1"
    "kind"       = "StorageClass"
    "metadata" = {
      "name"      = "${var.storage_class_name}"
      "namespace" = "workflows"
    }
    "provisioner"   = "efs.csi.aws.com"
    "parameters" = {
        "provisioningMode"      = "efs-ap"
        "fileSystemId"          = "${aws_efs_file_system.efs_data.id}"
        "directoryPerms"        = "700"
    }
  }
}


