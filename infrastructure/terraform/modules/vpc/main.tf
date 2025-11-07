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
    Name = "${var.project_name}-Private-${each.key}"
    type = "Private"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id   = aws_vpc.vpc.id
  for_each = var.private_subnets

  tags = {
    Name = "${var.project_name}-RT-${each.value.az}"
    Tier = "Private"
  }
}

resource "aws_route" "private_nat_route" {
  destination_cidr_block = "0.0.0.0/0"

  for_each       = aws_route_table.private_rt
  route_table_id = each.value.id
  nat_gateway_id = aws_nat_gateway.nat_gw[each.key].id
}

resource "aws_route_table_association" "private_rt_assoc" {
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt[each.key].id
}

resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true

  for_each          = var.public_subnets
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name = "${var.project_name}-Public-${each.key}"
    type = "Public"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-IGW"
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
    Name = "${var.project_name}-NACL-${each.value.az}"
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

resource "aws_network_acl_rule" "public_inbound_ephemeral" {
  for_each       = aws_network_acl.public_nacl
  network_acl_id = each.value.id
  rule_number    = 120
  rule_action    = "allow"
  protocol       = "tcp"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
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

resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  for_each   = var.public_subnets
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.project_name}-EIP-${each.value.az}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  connectivity_type = "public"
  depends_on        = [aws_internet_gateway.igw]

  for_each      = var.public_subnets
  subnet_id     = aws_subnet.public_subnets[each.key].id
  allocation_id = aws_eip.nat_eip[each.key].id

  tags = {
    Name = "${var.project_name}-NAT-GW-${each.value.az}"
  }
}

resource "aws_default_security_group" "default_sg_closed" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-CLOSED-Default-SG"
  }
}
