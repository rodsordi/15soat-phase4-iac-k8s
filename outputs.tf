output "cluster_name" {
  description = "EKS Cluster Name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Cluster Endpoint"
  value       = module.eks.cluster_endpoint
}

output "oidc_issuer" {
  description = "EKS OIDC Issuer URL"
  value       = module.eks.oidc_issuer
}

output "kafka_bootstrap_servers" {
  description = "Kafka cluster bootstrap servers"
  value       = module.kafka.bootstrap_servers
}

output "kubeconfig_command" {
  description = "Command to configure local kubectl context"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}
