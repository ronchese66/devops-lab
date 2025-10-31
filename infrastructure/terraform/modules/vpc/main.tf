resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = false


  for_each          = var.private_subnets
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = each.key
    type = "Private"
  }
}

resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true

  for_each          = var.public_subnets
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = each.key
    type = "Public"
  }
}
