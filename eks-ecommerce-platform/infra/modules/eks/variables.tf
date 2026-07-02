variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for worker nodes"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for control plane"
  type        = list(string)
}

variable "admin_iam_arn" {
  description = "IAM ARN for cluster admin access"
  type        = string
}

variable "ci_pipeline_iam_arn" {
  description = "IAM ARN for CI/CD pipeline access"
  type        = string
}