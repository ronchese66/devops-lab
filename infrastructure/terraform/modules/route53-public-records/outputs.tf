output "a_record_name" {
  value = aws_route53_record.immich_a_record.name
}

output "a_record_fqdn" {
  value = aws_route53_record.immich_a_record.fqdn
}

output "a_record_id" {
  value = aws_route53_record.immich_a_record.id
}