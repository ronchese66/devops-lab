resource "aws_security_group" "mount_targets" {
  name   = "${var.project_name}-efs-mount-targets"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-EFS-Mount-Targets-SG"
  }
}

resource "aws_security_group_rule" "mount_targets_inbound_nfs" {
  description              = "Allow NFS traffic from ECS tasks"
  security_group_id        = aws_security_group.mount_targets.id
  source_security_group_id = var.ecs_app_sg_id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 2049
  to_port   = 2049
}