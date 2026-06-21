variable "environment" { type = string }
variable "cluster_name" { type = string }
variable "vpc_name"    { type = string }
variable "vpc_cidr"    { type = string }

variable "public_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}

variable "private_app_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
}