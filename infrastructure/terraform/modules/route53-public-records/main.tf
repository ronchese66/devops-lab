resource "aws_route53_record" "immich_a_record" {
  zone_id = var.route53_public_hosted_zone_id
  name = var.domain_name
  type = "A"

  alias {
    name = var.alb_dns_name
    zone_id = var.alb_zone_id
    evaluate_target_health = true
  }
}