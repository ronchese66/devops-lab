resource "aws_security_group" "ecs_app_sg" {
  name   = "${var.project_name}-ecs-app-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-ECS-App-SG"
  }
}

resource "aws_security_group_rule" "ecs_app_inbound_alb" {
  description              = "Allow inbound traffic from Application Load Balancer"
  security_group_id        = aws_security_group.ecs_app_sg.id
  source_security_group_id = "LATER"
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 2283
  to_port                  = 2283
}

resource "aws_security_group_rule" "ecs_app_outbound_efs" {
  description              = "Allow outbound traffic to EFS"
  security_group_id        = aws_security_group.ecs_app_sg.id
  source_security_group_id = var.efs_mount_target_sg_id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 2049
  to_port                  = 2049
}

resource "aws_security_group_rule" "ecs_app_outbound_rds" {
  description              = "Allow outbound traffic to RDS"
  security_group_id        = aws_security_group.ecs_app_sg.id
  source_security_group_id = "LATER"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
}

resource "aws_security_group_rule" "ecs_app_outbound_redis" {
  description              = "Allow outbound traffic to Redis"
  security_group_id        = aws_security_group.ecs_app_sg.id
  source_security_group_id = "LATER"
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 6379
  to_port                  = 6379
}

resource "aws_security_group_rule" "ecs_app_outbound_ml" {
  description              = "Allow outbound traffic to ML containers"
  security_group_id        = aws_security_group.ecs_app_sg.id
  source_security_group_id = aws_security_group.ecs_ml_sg.id
  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 3003
  to_port                  = 3003
}

resource "aws_security_group_rule" "ecs_app_outbound_https" {
  description       = "Allow HTTPS outbound traffic"
  security_group_id = aws_security_group.ecs_app_sg.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
}

resource "aws_security_group" "ecs_ml_sg" {
  name   = "${var.project_name}-ecs-ml-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-ECS-ML-SG"
  }
}

resource "aws_security_group_rule" "ecs_ml_inbound_app" {
  description              = "Allow inbound traffic from App containers"
  security_group_id        = aws_security_group.ecs_ml_sg.id
  source_security_group_id = aws_security_group.ecs_app_sg.id
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 3003
  to_port                  = 3003
}

resource "aws_security_group_rule" "ecs_ml_outbound_https" {
  description       = "Allow HTTPS outbound"
  security_group_id = aws_security_group.ecs_ml_sg.id
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
}
