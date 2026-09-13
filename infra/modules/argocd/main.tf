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

  set {
    name  = "global.tolerations[0].key"
    value = "CriticalAddonsOnly"
  }

  set {
    name  = "global.tolerations[0].operator"
    value = "Exists"
  }

  set {
    name  = "global.tolerations[0].effect"
    value = "NoSchedule"
  }

  set {
    name  = "global.nodeSelector.role"
    value = "system"
  }

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  set {
    name  = "server.ingress.ingressClassName"
    value = "traefik"
  }

  set {
    name  = "server.ingress.hosts[0]"
    value = var.argocd_hostname
  }

  set {
    name  = "server.ingress.tls[0].secretName"
    value = "argocd-tls"
  }

  set {
    name  = "server.ingress.tls[0].hosts[0]"
    value = var.argocd_hostname
  }

  set {
    name  = "server.ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = "letsencrypt-prod"
  }

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }
}