resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.3.0"
  namespace        = "argocd"
  create_namespace = true

  depends_on = [var.cluster_endpoint]

  set {
    name  = "global.highAvailability.enabled"
    value = var.high_availability
  }

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }
}