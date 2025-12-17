resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "${var.project_name}-db-subnet-group"
  subnet_ids = values(var.private_subnet_ids)

  tags = {
    Name = "${var.project_name}-DB-Subnet-Group"
  }
}

resource "aws_rds_cluster" "rds_aurora_cluster" {
  cluster_identifier = "${var.project_name}-aurora-cluster"
  engine = "aurora-postgresql"
  engine_mode = "provisioned"

  database_name = "immich"
  master_username = "immich"
  master_password = var.db_password_value

  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.rds_aurora_psql_params.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  storage_encrypted = true
  kms_key_id = var.rds_key_arn

  backup_retention_period = var.rds_backup_retention_period
  preferred_backup_window = var.rds_preferred_backup_window
  preferred_maintenance_window = var.rds_preferred_maintenance_window
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.project_name}-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  deletion_protection = true
  apply_immediately = false

  serverlessv2_scaling_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  tags = {
    Name = "${var.project_name}-RDS-Aurora-Cluster"
  }

  lifecycle {
    ignore_changes = [ final_snapshot_identifier ]
  }
}

resource "aws_rds_cluster_instance" "rds_aurora_instance" {
  identifier = "${var.project_name}-instance-1"
  cluster_identifier = aws_rds_cluster.rds_aurora_cluster.id
  instance_class = "db.serverless"
  engine = aws_rds_cluster.rds_aurora_cluster.engine
  engine_version = aws_rds_cluster.rds_aurora_cluster.engine_version

  performance_insights_enabled = false
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring_role.arn

  tags = {
    Name = "${var.project_name}-RDS-Aurora-Instance-1"
  }
}