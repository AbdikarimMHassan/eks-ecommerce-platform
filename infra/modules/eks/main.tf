module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = var.cluster_name
  cluster_version = "1.33"

  vpc_id                         = var.vpc_id
  subnet_ids                     = var.private_subnet_ids
  control_plane_subnet_ids       = var.public_subnet_ids
  cluster_endpoint_public_access = true
  authentication_mode            = "API"

  eks_managed_node_groups = {
    system = {
      min_size       = var.eks_min_size
      max_size       = var.eks_max_size
      desired_size   = var.eks_desired_size
      instance_types = var.eks_node_instance_types
      disk_size      = var.eks_node_disk_size

      taints = [{
        key    = "CriticalAddonsOnly"
        value  = "true"
        effect = "NO_SCHEDULE"
      }]

      labels = {
        role = "system"
      }
    }
  }

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
  }

  access_entries = {
    admin = {
      principal_arn = var.admin_iam_arn
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
      principal_arn = var.ci_pipeline_iam_arn
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
    Environment              = var.environment
    Project                  = "ecommerce-platform"
    "karpenter.sh/discovery" = var.cluster_name
  }
}

