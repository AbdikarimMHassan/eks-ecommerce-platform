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
    name  = "server.ingress.hostname"
    value = var.argocd_hostname
  }

  set {
    name  = "server.ingress.tls"
    value = "true"
  }

  set {
    name  = "server.ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = "letsencrypt-prod"
  }

  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }
}

resource "kubectl_manifest" "root_app" {
  yaml_body = file("${path.root}/../../../manifest/argocd/root-app-${var.environment}.yaml")

  depends_on = [helm_release.argocd]
}