resource "aws_security_group" "alb_sg" {
  name = "${var.project_name}-alb-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-ALB-SG"
  }
}

resource "aws_security_group_rule" "alb_inbound_http" {
  description = "Allow HTTP traffic from Internet"
  security_group_id = aws_security_group.alb_sg.id
  type = "ingress"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 80
  to_port = 80
}

resource "aws_security_group_rule" "alb_inbound_https" {
  description = "Allow HTTPS traffic from Internet"
  security_group_id = aws_security_group.alb_sg.id
  type = "ingress"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 443
  to_port = 443
}

resource "aws_security_group_rule" "alb_outbound_ecs" {
  description = "Allow outbound traffic to ECS app containers"
  security_group_id = aws_security_group.alb_sg.id
  source_security_group_id = var.ecs_app_sg_id
  type = "egress"
  protocol = "tcp"
  from_port = 2283
  to_port = 2283
}