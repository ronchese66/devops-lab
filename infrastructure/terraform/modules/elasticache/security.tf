resource "aws_security_group" "redis_sg" {
  name = "${var.project_name}-redis-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-Redis-SG"
  }
}

resource "aws_security_group_rule" "redis_inbound_ecs_app" {
  description = "Allow inbound traffic from ECS conts"
  security_group_id = aws_security_group.redis_sg.id
  source_security_group_id = var.ecs_app_sg_id
  type = "ingress"
  protocol = "tcp"
  from_port = 6379
  to_port = 6379
}
