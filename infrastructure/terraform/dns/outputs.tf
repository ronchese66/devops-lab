output "route53_public_hosted_zone_id" {
  value = aws_route53_zone.route53_public_zone.zone_id
}

output "route53_nameservers" {
  value = aws_route53_zone.route53_public_zone.name_servers
}