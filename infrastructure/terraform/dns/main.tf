resource "aws_route53_zone" "route53_public_zone" {
  name = var.domain_name

  tags = {
    Name = "${var.project_name}-Public-Hosted-Zone"
  }
}