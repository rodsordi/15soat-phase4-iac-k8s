variable "namespace" {
  type        = string
  default     = "infra-ingress"
  description = "Namespace for Kong Ingress Controller"
}

variable "chart_version" {
  type        = string
  default     = "2.40.0"
  description = "Kong helm chart version"
}
