variable "namespace" {
  type        = string
  default     = "monitoring"
  description = "Namespace for monitoring tools"
}

variable "newrelic_license_key" {
  type        = string
  sensitive   = true
  description = "New Relic License Key"
}

variable "cluster_name" {
  type        = string
  description = "EKS Cluster Name"
}
