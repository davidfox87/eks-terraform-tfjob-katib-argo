# Resource: Kubernetes Storage Class
resource "kubernetes_storage_class_v1" "efs_sc" {  
  metadata {
    name = "${var.storage_class_name}"
  }
  storage_provisioner = "efs.csi.aws.com"  
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId =  aws_efs_file_system.efs_data.id
    directoryPerms = "777" # rwx for user, group, and rx for others
    gidRangeStart = "1000" # optional
    gidRangeEnd = "2000" # optional
    # assign a gid of 1500 to the pod and container using k8s securityContext
  }
}
