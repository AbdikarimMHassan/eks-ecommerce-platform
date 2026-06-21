locals {
  environment  = "dev"
  cluster_name = "ecommerce-eks-dev"
  vpc_name     = "ecommerce-vpc"
  vpc_cidr     = "10.1.0.0/16"
  

  public_subnets = {
    "public-2a" = { cidr_block = "10.1.1.0/24", availability_zone = "eu-west-2a" }
    "public-2b" = { cidr_block = "10.1.2.0/24", availability_zone = "eu-west-2b" }
  }

  private_app_subnets = {
    "private-2a" = { cidr_block = "10.1.11.0/24", availability_zone = "eu-west-2a" }
    "private-2b" = { cidr_block = "10.1.12.0/24", availability_zone = "eu-west-2b" }
  }

    #route53
  domain_name = "prod.my-ecommerce-store.com"

tags = {
    Environment = "development"
    Project     = "ecommerce-platform"
    ManagedBy   = "terraform"
    Owner       = "Abdikarim"
  }

}

}