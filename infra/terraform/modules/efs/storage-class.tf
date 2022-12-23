
data "aws_eks_cluster" "cluster" {
  name = "${var.cluster-id}"
}

data "aws_eks_cluster_auth" "cluster" {
  name = "${var.cluster-id}"
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

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


