variable "cluster-name" {
  type        = string
  description = "eks-cluster"
  default = "test-EKS-cluster"
}

variable "region" {
  description = "AWS region"
  type        = string
  default = "us-west-1"
}

