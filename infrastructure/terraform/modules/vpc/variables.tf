variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "project_name" {}

variable "public_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))

  default = {
    "1a" = {
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
    }
    "1b" = {
      cidr = "10.0.2.0/24"
      az   = "us-east-1b"
    }
  }
}

variable "private_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))

  default = {
    "1a" = {
      cidr = "10.0.101.0/24"
      az   = "us-east-1a"
    }
    "1b" = {
      cidr = "10.0.102.0/24"
      az   = "us-east-1b"
    }
  }
}

variable "flow_log_format" {
  type = string
  default = "$${account-id} $${action} $${bytes} $${dstaddr} $${dstport} $${end} $${flow-direction} $${instance-id} $${interface-id} $${packets} $${pkt-dstaddr} $${pkt-srcaddr} $${protocol} $${srcaddr} $${srcaddr} $${srcport} $${start} $${tcp-flags} $${type} $${vpc-id}"
}