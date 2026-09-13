variable "cluster_endpoint" {
  description = "EKS cluster endpoint: used to ensure cluster exists before installing ArgoCD"
  type        = string
}

variable "high_availability" {
  description = "Enable ArgoCD high availability"
  type        = bool
  default     = false
}

variable "argocd_hostname" {
  description = "Hostname for ArgoCD UI"
  type        = string
  default     = "argocd.abdikarim-tech.co.uk"
}