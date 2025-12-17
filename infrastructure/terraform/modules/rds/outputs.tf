output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}

output "rds_cluster_parameter_group_name" {
  value = aws_rds_cluster_parameter_group.rds_aurora_psql_params.name
}

output "rds_cluster_endpoint" {
  value = aws_rds_cluster.rds_aurora_cluster.endpoint
}