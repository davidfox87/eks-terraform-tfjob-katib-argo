resource "aws_efs_file_system" "efs_data" {
   creation_token = "efs"
   performance_mode = "generalPurpose"
   throughput_mode = "bursting"
   encrypted = "true"
 tags = {
     Name = "EFS"
   }
 }

# Mount to the subnets that will be using this efs volume
# Also attach sg's to restrict access to this volume
resource "aws_efs_mount_target" "efs-mt" {
    count = length(var.user_names)
    file_system_id  = aws_efs_file_system.efs_data.id
    subnet_id  = var.subnet_ids[count.index]
    security_groups = [
        var.aws_security_group_efs_id
    ]
}






resource "kubernetes_persistent_volume" "efs_data" {
  metadata {
    name = "pv-efsdata"

    labels = {
        app = "example"
    }
  }

  spec {
    access_modes = ["ReadOnlyMany"]

    capacity = {
      storage = "25Gi"
    }

    volume_mode                      = "Filesystem"
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "efs-sc"

    persistent_volume_source {
      csi {
        driver        = data.terraform_remote_state.csi.outputs.csi_name
        volume_handle = aws_efs_file_system.efs_data.id
        read_only    = true
      }
    }
  }
}