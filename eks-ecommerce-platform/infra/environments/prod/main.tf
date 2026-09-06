module "networking" {
  source              = "../../modules/networking"
  region              = "eu-west-2"
  environment         = local.environment
  cluster_name        = local.cluster_name
  vpc_name            = local.vpc_name
  vpc_cidr            = local.vpc_cidr
  public_subnets      = local.public_subnets
  private_app_subnets = local.private_app_subnets
}

module "eks" {
  source              = "../../modules/eks"
  cluster_name        = local.cluster_name
  environment         = local.environment
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  public_subnet_ids   = module.networking.public_subnet_ids
  admin_iam_arn       = local.admin_iam_arn
  ci_pipeline_iam_arn = local.ci_pipeline_iam_arn
}

module "karpenter" {
  source            = "../../modules/karpenter"
  cluster_name      = local.cluster_name
  environment       = local.environment
  oidc_provider_arn = module.eks.oidc_provider_arn
}

module "argocd" {
  source            = "../../modules/argocd"
  cluster_endpoint  = module.eks.cluster_endpoint
  high_availability = true
}

module "ecr" {
  source      = "../../modules/ecr"
  environment = local.environment
}

module "dns" {
  source      = "../../modules/dns"
  domain_name = local.domain_name
  environment = local.environment
}