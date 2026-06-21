variable "eks_node_instance_types" {
  type        = list(string)
  description = "The EC2 instance types for the EKS worker nodes"}

variable "eks_desired_size" {
  type        = number
  description = "The initial desired number of worker nodes to spin up"
}

variable "eks_min_size" {
  type        = number
  description = "The minimum number of worker nodes the auto-scaling group can scale down to"
}

variable "eks_max_size" {
  type        = number
  description = "The maximum number of worker nodes the auto-scaling group can scale up to"
}