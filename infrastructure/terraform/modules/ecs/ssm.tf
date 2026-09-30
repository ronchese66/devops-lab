resource "aws_ssm_service_setting" "ssm_block_public_sharing" {
  setting_id    = "/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"
}