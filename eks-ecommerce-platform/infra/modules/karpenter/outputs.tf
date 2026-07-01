output "node_iam_role_arn" {
  description = "IAM role ARN for nodes Karpenter provisions. needed in EC2NodeClass"
  value       = module.karpenter.node_iam_role_arn
}

output "irsa_arn" {
  description = "IRSA ARN for Karpenter controller ServiceAccount"
  value       = module.karpenter.irsa_arn
}