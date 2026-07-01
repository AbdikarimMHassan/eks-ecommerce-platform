locals {
  environment  = "prod"
  cluster_name = "ecommerce-eks-prod"
  vpc_name     = "ecommerce-vpc"
  vpc_cidr     = "10.0.0.0/16"


  public_subnets = {
    "public-2a" = { cidr_block = "10.0.1.0/24", availability_zone = "eu-west-2a" }
    "public-2b" = { cidr_block = "10.0.2.0/24", availability_zone = "eu-west-2b" }
    "public-2c" = { cidr_block = "10.0.3.0/24", availability_zone = "eu-west-2c" }
  }

  private_app_subnets = {
    "private-2a" = { cidr_block = "10.0.11.0/24", availability_zone = "eu-west-2a" }
    "private-2b" = { cidr_block = "10.0.12.0/24", availability_zone = "eu-west-2b" }
    "private-2c" = { cidr_block = "10.0.13.0/24", availability_zone = "eu-west-2c" }
  }

  eks_node_instance_types = ["m5.large"] 
  eks_min_size            = 3
  eks_max_size            = 6
  eks_desired_size        = 3

  
  domain_name = "prod.my-ecommerce-store.com"

tags = {
    Environment = "production"
    Project     = "ecommerce-platform"
    ManagedBy   = "terraform"
    Owner       = "Abdikarim"
  }

}


locals {
  region              = "eu-west-2"
  admin_iam_arn       = "arn:aws:iam::779846800049:user/akarim"
  ci_pipeline_iam_arn = "arn:aws:iam::779846800049:role/github-actions-eks-deployer"
}