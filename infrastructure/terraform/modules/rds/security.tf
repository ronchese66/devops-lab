resource "aws_security_group" "rds_sg" {
  name = "${var.project_name}-rds-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-RDS-SG"
  }
}

resource "aws_security_group_rule" "rds_inbound_ecs_app" {
  description = "Allow inbound traffic from ECS App containers"
  security_group_id = aws_security_group.rds_sg.id
  source_security_group_id = var.ecs_app_sg_id
  type = "ingress"
  protocol = "tcp"
  from_port = 5432
  to_port = 5432    
}

resource "aws_security_group_rule" "rds_inbound_vpc_cidr" {
  description = "Allow inbound from VPC CIDR (SSM/Exec)"
  security_group_id = aws_security_group.rds_sg.id
  cidr_blocks = [var.vpc_cidr]
  type = "ingress"
  protocol = "tcp"
  from_port = 5432
  to_port = 5432
}

resource "aws_iam_role" "rds_enhanced_monitoring_role" {
  name = "${var.project_name}-rds-enhanced-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
                Service = "monitoring.rds.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
    ]
  })

  tags = {
    Name = "${var.project_name}-RDS-Enhanced-Monitoring-Role"
  }
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring_policy" {
  role = aws_iam_role.rds_enhanced_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}