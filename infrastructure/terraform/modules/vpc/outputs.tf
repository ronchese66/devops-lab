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

output "private_subnet_arns" {
  value = [for s in aws_subnet.private_subnets : s.arn]
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

output "s3_endpoint_id" {
  value = aws_vpc_endpoint.s3_gateway.id
}

output "s3_endpoint_prefix_list_id" {
  value = aws_vpc_endpoint.s3_gateway.prefix_list_id
}

output "flow_logs_s3_bucket_id" {
  value = aws_s3_bucket.flow_logs.id
}

output "flow_logs_s3_bucket_arn" {
  value = aws_s3_bucket.flow_logs.arn
}

output "flow_logs_s3_bucket_name" {
  value = aws_s3_bucket.flow_logs.bucket
}

output "flow_logs_iam_role_arn" {
  value = aws_iam_role.flow_logs_role.arn
}

output "flow_log_id" {
  value = aws_flow_log.vpc_flow_logs.id
}