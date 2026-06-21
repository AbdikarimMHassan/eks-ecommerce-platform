module "cert_manager_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.34"

  role_name                  = "${local.cluster_name}-cert-manager"
  attach_cert_manager_policy = true
  
  # LEAST PRIVILEGE: Dynamically feed the zone ARN created above
  cert_manager_hosted_zone_arns = [aws_route53_zone.primary.arn]

  oidc_providers = {
    eks = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["cert-manager:cert-manager"]
    }
  }

  tags = local.tags
}

module "external_dns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.34"

  role_name                  = "${local.cluster_name}-external-dns"
  attach_external_dns_policy = true
  
  # LEAST PRIVILEGE: Dynamically feed the zone ARN created above
  external_dns_hosted_zone_arns = [aws_route53_zone.primary.arn]

  oidc_providers = {
    eks = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }

  tags = local.tags
}