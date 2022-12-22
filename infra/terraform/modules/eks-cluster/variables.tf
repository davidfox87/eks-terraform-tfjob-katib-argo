variable "cluster-name" {
  type        = string
  description = "eks-cluster"
}

variable "subnets" {
  type  = list
  description = "vpc subnets"
}

variable "vpc_id" {
  type  = string
  description = "vpc id"
}

variable "kubernetes_version" {
  type    = string
  default = "1.21"
}

variable "role_policy_arns" {
  description = "ARNs of any policies to attach to the IAM role"
  type        = map(string)
  default     = {}
}



variable "cluster_name" {
  type    = string
  default = "test-cluster"
}

variable "min_node_count" {
  type    = number
  default = 3
}

variable "max_node_count" {
  type    = number
  default = 9
}

variable "machine_type" {
  type    = string
  default = "t2.medium"
}

variable "region" {
  type    = string
  default = "us-west-1"
}


variable "addons" {
  type = list(object({
    name    = string
    version = string
  }))

  default = [
    {
      name    = "kube-proxy"
      version = "v1.21.2-eksbuild.2"
    },
    {
      name    = "vpc-cni"
      version = "v1.10.1-eksbuild.1"
    },
    {
      name    = "coredns"
      version = "v1.8.4-eksbuild.1"
    },
    {
      name    = "aws-ebs-csi-driver"
      version = "v1.4.0-eksbuild.preview"
    }
  ]
}