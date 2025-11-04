module "vpc" {
  source       = "git::https://github.com/ronchese66/devops-lab.git//infrastructure/terraform/modules/vpc?ref=v1.2.0"
  project_name = var.project_name
}