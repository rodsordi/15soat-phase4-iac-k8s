variable "cluster_name" {
  type        = string
  description = "EKS Cluster Name"
}

variable "cluster_version" {
  type    = string
  default = "1.30"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private Subnet IDs for EKS nodes"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3a.large"]
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 5
}

variable "node_desired_size" {
  type    = number
  default = 3
}

variable "environment" {
  type    = string
  default = "prd"
}

variable "use_existing_lab_role" {
  type        = bool
  description = "Whether to use pre-created AWS Academy LabRole instead of creating new IAM roles"
  default     = true
}

variable "lab_role_name" {
  type        = string
  description = "Name of the existing IAM LabRole in AWS Academy"
  default     = "LabRole"
}
