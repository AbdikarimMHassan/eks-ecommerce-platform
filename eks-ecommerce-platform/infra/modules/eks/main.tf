module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  # Cluster Metadata
  cluster_name    = local.cluster_name
  cluster_version = "1.33"

  
  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnet_ids
  control_plane_subnet_ids = var.public_subnet_ids

  cluster_endpoint_public_access = true
  
  
  authentication_mode = "API"

  
  eks_managed_node_groups = {
    default = {
      min_size       = var.eks_min_size
      max_size       = var.eks_max_size
      desired_size   = var.eks_desired_size
      instance_types = var.eks_node_instance_types
      disk_size      = 50
    }
  }

  
  access_entries = {
    admin = {
      principal_arn = "arn:aws:iam::779846800049:user/akarim"
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
    
    
    ci_pipeline = {
      principal_arn = "arn:aws:iam::779846800049:role/github-actions-eks-deployer" 
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    Environment = local.environment
    Project     = "ecommerce-platform"
  }
}