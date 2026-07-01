variable "cluster_endpoint" {
  description = "EKS cluster endpoint. Ensure cluster exists before installing ArgoCD"
  type        = string
}

variable "high_availability" {
  description = "Enable ArgoCD high availability"
  type        = bool
  
}