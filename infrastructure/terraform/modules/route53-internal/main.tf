resource "aws_route53_zone" "route53_private_zone" {
  name = "${var.project_name}.internal"

  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Name = "${var.project_name}-Private-Zone"
  }
}

resource "aws_route53_record" "route53_database_record" {
  zone_id = aws_route53_zone.route53_private_zone.zone_id
  name    = "database"
  type    = "CNAME"
  ttl     = var.dns_ttl
  records = ["LATER"] # RDS cluster endp
}

resource "aws_route53_record" "route53_redis_record" {
  zone_id = aws_route53_zone.route53_private_zone.zone_id
  name    = "redis"
  type    = "CNAME"
  ttl     = var.dns_ttl
  records = ["LATER"] # Redis prim endp
}

resource "aws_route53_record" "route53_monitoring_record" {
  zone_id = aws_route53_zone.route53_private_zone.zone_id
  name    = "monitoring"
  type    = "CNAME"
  ttl     = var.dns_ttl
  records = ["LATER"]
}



