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
  default = "password"
}
variable "insecure" {
  type = bool
  default = true
}
variable "argocd_values_file" {
  type = string
  description = "location of values.yaml for helm install"
  default = "argocd_apps_values.yaml"
}