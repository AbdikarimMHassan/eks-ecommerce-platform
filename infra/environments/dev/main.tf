terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

module "networking" {
  source = "../../modules/networking"

  environment         = local.environment
  cluster_name        = local.cluster_name
  vpc_name            = local.vpc_name
  vpc_cidr            = local.vpc_cidr
  public_subnets      = local.public_subnets
  private_app_subnets = local.private_app_subnets
}