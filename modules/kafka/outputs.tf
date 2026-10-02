output "bootstrap_servers" {
  description = "Kafka internal bootstrap servers"
  value       = "kafka-cluster-kafka-bootstrap.${var.namespace}.svc.cluster.local:9092"
}

output "namespace" {
  value = var.namespace
}
