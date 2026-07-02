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
      min_size       = 2
      max_size       = 3
      desired_size   = 2
      instance_types = ["m5.large"]
      disk_size      = 50

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

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

  tags = {
    Environment              = var.environment
    Project                  = "ecommerce-platform"
    "karpenter.sh/discovery" = var.cluster_name
  }
}