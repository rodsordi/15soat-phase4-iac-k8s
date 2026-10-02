variable "namespace" {
  type        = string
  default     = "infra-kafka"
  description = "Namespace for Kafka cluster"
}

variable "operator_version" {
  type        = string
  default     = "0.41.0"
  description = "Strimzi Kafka Operator version"
}
