
variable "eks_node_instance_types" {
  type        = list(string)
  description = "The EC2 instance types for the EKS worker nodes"
}

variable "eks_desired_size" {
  type        = number
  description = "Desired number of worker nodes"
}

variable "eks_min_size" {
  type        = number
  description = "Minimum number of worker nodes"
}

variable "eks_max_size" {
  type        = number
  description = "Maximum number of worker nodes"
}

variable "region" {
  description = "The AWS region"
  type        = string
}