module "cert_manager_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.34"

  role_name                  = "${local.cluster_name}-cert-manager"
  attach_cert_manager_policy = true


  cert_manager_hosted_zone_arns = [module.dns.zone_arn]

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


  external_dns_hosted_zone_arns = [module.dns.zone_arn]

  oidc_providers = {
    eks = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }

  tags = local.tags
}

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.34"

  role_name             = "${local.cluster_name}-ebs-csi-driver"
  attach_ebs_csi_policy = true

  oidc_providers = {
    eks = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

module "external_secrets_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.34"

  role_name                             = "${local.cluster_name}-external-secrets"
  attach_external_secrets_policy        = true
  external_secrets_secrets_manager_arns = [
    module.secrets_manager.postgres_secret_arn,
    module.secrets_manager.redis_secret_arn,
    module.secrets_manager.jwt_secret_arn
  ]

  oidc_providers = {
    eks = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }
}


# order-service: publish to SQS
module "order_service_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.34"

  role_name = "${local.cluster_name}-order-service"

  role_policy_arns = {
    sqs = aws_iam_policy.sqs_publish.arn
  }

  oidc_providers = {
    eks = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["ecommerce-prod:order-service-sa"]
    }
  }
}

# payment-service: publish to SQS
module "payment_service_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.34"

  role_name = "${local.cluster_name}-payment-service"

  role_policy_arns = {
    sqs = aws_iam_policy.sqs_publish.arn
  }

  oidc_providers = {
    eks = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["ecommerce-prod:payment-service-sa"]
    }
  }
}

# inventory-service: publish to SQS
module "inventory_service_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.34"

  role_name = "${local.cluster_name}-inventory-service"

  role_policy_arns = {
    sqs = aws_iam_policy.sqs_publish.arn
  }

  oidc_providers = {
    eks = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["ecommerce-prod:inventory-service-sa"]
    }
  }
}

# worker: consume from SQS
module "worker_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.34"

  role_name = "${local.cluster_name}-worker"

  role_policy_arns = {
    sqs = aws_iam_policy.sqs_consume.arn
  }

  oidc_providers = {
    eks = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["ecommerce-prod:worker-sa"]
    }
  }
}


# SQS publish policy: shared by order, payment and inventory
resource "aws_iam_policy" "sqs_publish" {
  name        = "${local.cluster_name}-sqs-publish"
  description = "Allow publishing to ecommerce SQS queue"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage", "sqs:GetQueueAttributes"]
        Resource = module.sqs.queue_arn
      }
    ]
  })
}

# SQS consume policy: for worker only
resource "aws_iam_policy" "sqs_consume" {
  name        = "${local.cluster_name}-sqs-consume"
  description = "Allow consuming from ecommerce SQS queue"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = module.sqs.queue_arn
      }
    ]
  })
}