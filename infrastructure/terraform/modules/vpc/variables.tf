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
    "public-1a" = {
      cidr = "10.0.1.0/24"
      az   = "us-east-1a"
    }
    "public-1b" = {
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
    "private-1a" = {
      cidr = "10.0.101.0/24"
      az   = "us-east-1a"
    }
    "private-1b" = {
      cidr = "10.0.102.0/24"
      az   = "us-east-1b"
    }
  }
}