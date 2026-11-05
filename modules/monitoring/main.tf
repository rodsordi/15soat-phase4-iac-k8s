resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "newrelic_bundle" {
  name       = "newrelic-bundle"
  repository = "https://helm-charts.newrelic.com"
  chart      = "nri-bundle"
  version    = "5.0.108"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  wait       = false

  set_sensitive {
    name  = "global.licenseKey"
    value = var.newrelic_license_key
  }

  set {
    name  = "global.cluster"
    value = var.cluster_name
  }

  set {
    name  = "infrastructure.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.enabled"
    value = "true"
  }

  set {
    name  = "logging.enabled"
    value = "true"
  }

  set {
    name  = "kube-state-metrics.enabled"
    value = "true"
  }
}
