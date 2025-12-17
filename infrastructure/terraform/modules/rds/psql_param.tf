resource "aws_rds_cluster_parameter_group" "rds_aurora_psql_params" {
  name = "${var.project_name}-aurora-psql-parameters"
  family = "aurora-postgresql16"

  parameter {
    name = "log_statement"
    value = "mod"
  }

  parameter {
    name = "work_mem"
    value = "16384"
  }

  parameter {
    name = "maintenance_work_mem"
    value = "262144"
  }

  parameter {
    name = "random_page_cost"
    value = "1.1"
  }

  tags = {
    Name = "${var.project_name}-RDS-Aurora-PostgreSQL-Cluster-Param-Group"
  }
}