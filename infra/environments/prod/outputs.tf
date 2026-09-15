output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "karpenter_node_role" {
  description = "IAM role name for nodes Karpenter provisions. Used in karpenter-values.yaml"
  value       = module.karpenter.node_iam_role_arn
}

output "hosted_zone_id" {
  description = "Route53 hosted zone ID.  Used in cert-manager ClusterIssuer"
  value       = module.dns.zone_id
}

output "ecr_repository_urls" {
  description = "ECR repository URLs for all services"
  value       = module.ecr.repository_urls
}

output "sqs_queue_url" {
  description = "SQS queue URL — use in service values files"
  value       = module.sqs.queue_url
}