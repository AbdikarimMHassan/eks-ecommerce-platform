resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = data.aws_eks_addon_version.ebs_csi.version
  service_account_role_arn = module.ebs_csi_irsa.iam_role_arn

  depends_on = [module.eks, module.ebs_csi_irsa]
}

data "aws_eks_addon_version" "ebs_csi" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = "1.33"
  most_recent        = true
}