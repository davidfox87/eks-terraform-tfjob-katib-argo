variable "subnet_ids" {
  description = "Subnet Ids"
  type        = list(string)
}

variable "aws_security_group_efs_id" {
    description = "NFS access to EFS from EKS worker nodes"
    type        = string
}

variable "storage_class_name" {
    description = "name of storage class"
    type        = string
}