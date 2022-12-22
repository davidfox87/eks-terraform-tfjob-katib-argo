resource "kubectl_manifest" "storage_class" {
  yaml_body  = <<YAML
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: ${var.storage_class_name}
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: ${aws_efs_file_system.efs_data.id}
  directoryPerms: "700"
YAML
}