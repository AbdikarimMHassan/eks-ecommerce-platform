module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  # Cluster Metadata
  cluster_name    = local.cluster_name
  cluster_version = "1.33"

  # Networking Setup (Connecting directly to your networking module outputs)
  vpc_id                   = module.networking.vpc_id
  subnet_ids               = module.networking.private_subnet_ids
  control_plane_subnet_ids = module.networking.public_subnet_ids

  # Security & Endpoint Configurations
  cluster_endpoint_public_access = true
  
  # CRITICAL: Forces EKS to use native AWS Access Entries (bypasses old aws-auth configmap)
  authentication_mode = "API"

  # Production-tuned Managed Node Groups mapped to your dynamic input variables
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