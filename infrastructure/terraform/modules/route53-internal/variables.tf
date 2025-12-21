variable "project_name" {}

variable "vpc_id" {}

variable "dns_ttl" {
  type = number
}

variable "rds_cluster_endpoint" {}

variable "redis_prim_endpoint" {}