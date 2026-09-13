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

variable "eks_node_instance_types" {
  description = "Instance types for EKS worker nodes"
  type        = list(string)
}

variable "eks_min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
}

variable "eks_max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
}

variable "eks_desired_size" {
  description = "Desired size of the EKS node group"
  type        = number
}

variable "eks_node_disk_size" {
  description = "Disk size for EKS worker nodes in GB"
  type        = number
}