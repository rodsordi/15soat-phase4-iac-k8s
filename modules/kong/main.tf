resource "kubernetes_namespace" "kong" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "kong" {
  name       = "kong"
  repository = "https://charts.konghq.com"
  chart      = "kong"
  version    = var.chart_version
  namespace  = kubernetes_namespace.kong.metadata[0].name

  set {
    name  = "ingressController.enabled"
    value = "true"
  }

  set {
    name  = "ingressController.ingressClass"
    value = "kong"
  }

  set {
    name  = "proxy.type"
    value = "LoadBalancer"
  }

  set {
    name  = "proxy.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  set {
    name  = "proxy.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-scheme"
    value = "internet-facing"
  }
}
