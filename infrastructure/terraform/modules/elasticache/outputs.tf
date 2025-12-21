output "redis_sg_id" {
  value = aws_security_group.redis_sg.id
}

output "redis_prim_endpoint" {
  value = aws_elasticache_replication_group.redis_replic_group.primary_endpoint_address
}