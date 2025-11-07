output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnet_ids" {
  value = { for k, v in aws_subnet.public_subnets : k => v.id }
}

output "private_subnet_ids" {
  value = { for k, v in aws_subnet.private_subnets : k => v.id }
}

output "public_route_table_id" {
  value = aws_route_table.public_rt.id
}

output "private_route_table_ids" {
  value = { for k, v in aws_route_table.private_rt : k => v.id }
}

output "nat_gateway_ids" {
  value = { for k, v in aws_nat_gateway.nat_gw : k => v.id }
}

output "nat_eip" {
  value = { for k, v in aws_eip.nat_eip : k => v.public_ip }
}
