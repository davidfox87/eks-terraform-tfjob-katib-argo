variable "cluster-name" {
  type        = string
  description = "eks-cluster"
}

variable "subnets" {
  type  = list
  description = "private subnets"
}
variable "control_plane_subnet_ids" {
  type  = list
  description = "public subnets"
}

variable "vpc_id" {
  type  = string
  description = "vpc id"
}

variable "cluster_version" {
  type    = string
  default = "1.24"
}

variable "role_policy_arns" {
  description = "ARNs of any policies to attach to the IAM role"
  type        = map(string)
  default     = {}
}


variable "min_node_count" {
  type    = number
  default = 3
}

variable "max_node_count" {
  type    = number
  default = 9
}

variable "instance_type" {
  type    = string
  default = "t2.medium"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "addons" {
  description = "Map of cluster addon configurations to enable for the cluster. Addon name can be the map keys or set with `name`"
  type        = any
  default     = {}
}


#### aws-auth #####

variable "map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "map_additional_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

