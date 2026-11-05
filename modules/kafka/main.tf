resource "kubernetes_namespace" "kafka" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "strimzi_operator" {
  name       = "strimzi-kafka-operator"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  version    = var.operator_version
  namespace  = kubernetes_namespace.kafka.metadata[0].name
  wait       = true
  timeout    = 300
}

resource "kubernetes_manifest" "kafka_cluster" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaNodePool"
    metadata = {
      name      = "dual-role"
      namespace = kubernetes_namespace.kafka.metadata[0].name
      labels = {
        "strimzi.io/cluster" = "kafka-cluster"
      }
    }
    spec = {
      replicas = 3
      roles    = ["controller", "broker"]
      storage = {
        type = "ephemeral"
      }
    }
  }

  depends_on = [helm_release.strimzi_operator]
}

resource "kubernetes_manifest" "kafka_broker" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "Kafka"
    metadata = {
      name      = "kafka-cluster"
      namespace = kubernetes_namespace.kafka.metadata[0].name
      annotations = {
        "strimzi.io/node-pools" = "enabled"
        "strimzi.io/kraft"      = "enabled"
      }
    }
    spec = {
      kafka = {
        version = "3.8.0"
        listeners = [
          {
            name = "plain"
            port = 9092
            type = "internal"
            tls  = false
          }
        ]
        config = {
          "offsets.topic.replication.factor"         = 3
          "transaction.state.log.replication.factor" = 3
          "transaction.state.log.min.isr"            = 2
          "default.replication.factor"               = 3
          "min.insync.replicas"                      = 2
        }
      }
      entityOperator = {
        topicOperator = {}
        userOperator  = {}
      }
    }
  }

  depends_on = [kubernetes_manifest.kafka_cluster]
}
