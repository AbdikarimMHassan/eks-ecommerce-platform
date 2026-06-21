resource "helm_release" "argo_cd_deployment" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.3.0"
  namespace        = "argocd"
  create_namespace = true

  # CRITICAL: Ensures the cluster exists first
  depends_on = [module.eks]

  # Development High Availability configurations
  set {
    name  = "global.highAvailability.enabled"
    value = local.environment == "dev" ? "true" : "false"
  }

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }
}