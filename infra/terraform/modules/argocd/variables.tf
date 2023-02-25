

variable "enable_dex" {
  type        = bool
  description = "Enabled the dex server?"
  default     = true
}

variable "insecure" {
  type        = bool
  description = "Disable TLS on the ArogCD API Server? (adds the --insecure flag to the argocd-server command)"
  default     = false
}


variable "admin_password" {
  description = "Default Admin Password"
  type        = string
  default     = ""
}
variable "argocd_ingress_enabled" {
  description = "Create an ingress for argocd UI or not?"
  type        = bool
  default     = false
}

variable "argocd_server_host" {
  description = "host name to access argocd-server ui"
  type        = string
  default     = "ds-argocd.dishtv.technology"
}

variable "ingress_alb_security_groups" {
  description = "sg for ingress-managed ALB"
  type = list(string)
}

variable "acm_certificate_arn" {
  description = "AWS ACM Certificate ARN to attach to ingress annotations"
  type = string
}