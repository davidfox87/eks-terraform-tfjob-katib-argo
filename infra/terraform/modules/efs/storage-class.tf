resource "kubectl_manifest" "storage_class" {
  yaml_body  = <<YAML
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ${var.storage_class_name}
provisioner: efs.csi.aws.com
YAML
  depends_on = [helm_release.kubernetes_efs_csi_driver]
}