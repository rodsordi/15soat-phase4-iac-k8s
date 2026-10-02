variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "prd"
}

variable "cluster_name" {
  type        = string
  description = "Name of the EKS cluster"
  default     = "fiap-workshop-eks"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.30"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "node_instance_types" {
  type        = list(string)
  description = "Instance types for EKS worker nodes"
  default     = ["t3a.large"]
}

variable "node_min_size" {
  type        = number
  description = "Minimum number of worker nodes"
  default     = 2
}

variable "node_max_size" {
  type        = number
  description = "Maximum number of worker nodes"
  default     = 5
}

variable "node_desired_size" {
  type        = number
  description = "Desired number of worker nodes"
  default     = 3
}

variable "newrelic_license_key" {
  type        = string
  description = "New Relic license key for OTLP observability"
  sensitive   = true
  default     = "NRJS-DUMMY-LICENSE-KEY"
}
