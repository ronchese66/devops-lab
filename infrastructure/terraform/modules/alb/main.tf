resource "aws_lb" "immich_alb" {
  name = "${var.project_name}-alb"
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_sg.id]
  subnets = values(var.public_subnet_ids)

  enable_deletion_protection = true
  enable_cross_zone_load_balancing = true
  enable_http2 = true
  drop_invalid_header_fields = true
  ip_address_type = "ipv4"
  idle_timeout = 4000

  tags = {
    Name = "${var.project_name}-ALB"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name = "${var.project_name}-app-tg"
  vpc_id = var.vpc_id
  protocol = "HTTP"
  target_type = "ip"
  port = 2283
  deregistration_delay = 120

  health_check {
    enabled = true
    path = "/server/ping"
    protocol = "HTTP"
    port = "traffic-port"
    healthy_threshold = 2
    unhealthy_threshold = 3
    timeout = 5
    interval = 30
    matcher = "200"
  }

  stickiness {
    enabled = false
    type = "lb_cookie"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-App-Target-Group"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.immich_alb.arn
  protocol = "HTTP"
  port = 80

  default_action {
    type = "redirect"

    redirect {
      protocol = "HTTPS"
      port = "443"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name = "${var.project_name}-HTTP-Listener"
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.immich_alb.arn
  protocol = "HTTPS"
  port = 443
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = var.certificate_arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

  tags = {
    Name = "${var.project_name}-HTTPS-Listener"
  }
}