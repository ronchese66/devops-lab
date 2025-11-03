resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }

  lifecycle {
    prevent_destroy = true
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

  lifecycle {
    prevent_destroy = true
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

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-IGW"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-Public-RT"
    Tier = "Public"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_rt_assoc" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_network_acl" "public_nacl" {
  vpc_id   = aws_vpc.vpc.id
  for_each = var.public_subnets

  tags = {
    Name = "${var.project_name}-Public-NACL-${each.value.az}"
    Tier = "Public"
  }
}

resource "aws_network_acl_rule" "public_inbound_https" {
  for_each       = aws_network_acl.public_nacl
  network_acl_id = each.value.id
  rule_number    = 100
  protocol       = "tcp"
  egress         = false
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "public_inbound_icmp" {
  for_each       = aws_network_acl.public_nacl
  network_acl_id = each.value.id
  rule_number    = 110
  egress         = false
  protocol       = "icmp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  icmp_type      = -1
  icmp_code      = -1
}

resource "aws_network_acl_rule" "public_outbound_all" {
  for_each       = aws_network_acl.public_nacl
  network_acl_id = each.value.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_association" "public_nacl_assoc" {
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
  network_acl_id = aws_network_acl.public_nacl[each.key].id
}

