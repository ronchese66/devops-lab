resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name = "${var.project_name}-redis-subnet-group"
  subnet_ids = values(var.private_subnet_ids)

  tags = {
    Name = "${var.project_name}-Redis-Subnet-Group"
  }
}

resource "aws_elasticache_parameter_group" "redis_params" {
  name = "${var.project_name}-redis-params"
  family = "redis7"

  parameter {
    name = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name = "tcp-keepalive"
    value = "300"
  }

  tags = {
    Name = "${var.project_name}-Redis-Parameter-Group"
  }
}

resource "aws_elasticache_replication_group" "redis_replic_group" {
  description = "Redis Replication Group"
  replication_group_id = "${var.project_name}-redis"
  parameter_group_name = aws_elasticache_parameter_group.redis_params.name

  subnet_group_name = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids = [aws_security_group.redis_sg.id]

  engine = "redis"
  engine_version = "7.2"
  node_type = "cache.t4g.small"
  num_cache_clusters = 2
  port = 6379

  at_rest_encryption_enabled = true
  transit_encryption_enabled = false

  automatic_failover_enabled = true
  multi_az_enabled = true
  auto_minor_version_upgrade = true

  maintenance_window = var.redis_maintenance_window
  snapshot_retention_limit = 0

  log_delivery_configuration {
    destination = aws_cloudwatch_log_group.redis_engine_log.name
    destination_type = "cloudwatch-logs"
    log_format = "json"
    log_type = "engine-log"
  }

  tags = {
    Name = "${var.project_name}-Redis-Replication-Group"
  }
}