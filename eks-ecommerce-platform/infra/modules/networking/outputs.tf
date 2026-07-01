output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = [for subnet in aws_subnet.private_app_subnets : subnet.id]
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public_subnets : subnet.id]
}

output "private_subnet_cidrs" {
  value = [for subnet in aws_subnet.private_app_subnets : subnet.cidr_block]
}

output "vpc_endpoint_sg_id" {
  description = "Security group ID attached to Interface endpoints.
  value       = aws_security_group.vpc_endpoints.id
}

output "private_route_table_ids" {
  value = [for rt in aws_route_table.private_rt : rt.id]
}