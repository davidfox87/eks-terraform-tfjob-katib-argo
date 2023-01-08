
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

variable "values_file" {
  description = "The name of the ArgoCD helm chart values file to use"
  type        = string
  default     = "values.yaml"
}

variable "admin_password" {
  description = "Default Admin Password"
  type        = string
  default     = ""
}