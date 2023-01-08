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

variable "admin_password" {
  type = string
  description = "password for argocd"
}
variable "insecure" {
  type = bool
}
variable "argocd_values_file" {
  type = string
  description = "location of values.yaml for helm install"
  default = "values.yaml"
}