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

variable "newrelic_account_id" {
  type        = string
  description = "New Relic Account ID"
  default     = "0"
}

variable "newrelic_api_key" {
  type        = string
  sensitive   = true
  description = "New Relic User API Key (NRAK-...)"
  default     = ""
}

variable "workload_namespace" {
  type        = string
  default     = "fiap-workshop"
  description = "Namespace where phase4 microservices are deployed"
}
