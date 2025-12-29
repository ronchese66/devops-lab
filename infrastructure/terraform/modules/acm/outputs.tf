output "certificate_arn" {
  value = aws_acm_certificate_validation.cert_validation.certificate_arn
}

output "certificate_id" {
  value = aws_acm_certificate.immich_cert.id
}

output "certificate_domain_name" {
  value = aws_acm_certificate.immich_cert.domain_name
}

output "certificate_status" {
  value = aws_acm_certificate.immich_cert.status
}