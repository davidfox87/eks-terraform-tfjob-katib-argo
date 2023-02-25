variable "cluster-name" {
  type        = string
  description = "eks-cluster"
  default = "test-EKS-cluster"
}

variable "region" {
  description = "AWS region"
  type        = string
  default = "us-west-2"
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

variable "argocd-url" {
  description = "Route53 URL to access argocd UI"
  type = string
  default = "ds-argocd.mlops-playground.com"
}
