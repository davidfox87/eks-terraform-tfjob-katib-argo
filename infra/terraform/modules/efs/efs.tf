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





