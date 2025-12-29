output "alb_id" {
  value = aws_lb.immich_alb.id
}

output "alb_arn" {
  value = aws_lb.immich_alb.arn
}

output "alb_dns_name" {
  value = aws_lb.immich_alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.immich_alb.zone_id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "app_target_group_name" {
  value = aws_lb_target_group.app_tg.name
}

output "app_target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}

output "http_listener_arn" {
  value = aws_lb_listener.http_listener.arn
}

output "https_listener_arn" {
  value = aws_lb_listener.https_listener.arn
}