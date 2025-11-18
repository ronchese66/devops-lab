variable "project_name" {}

variable "vpc_id" {}

variable "subnet_ids" {}

variable "cluster_version" {
  default = "1.31"
}

variable "kms_key_arn" {
  nullable = false
}

variable "endpoint_public_access" {
  default = false
}

variable "endpoint_private_access" {
  default = true
}

variable "public_access_cidrs" {}

variable "cluster_name" {}

