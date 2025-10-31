module "vpc" {
  source = "git::https://github.com/ronchese66/devops-lab.git//infrastructure/terraform/modules/vpc?ref=v1.0.0"
  project_name = var.project_name
}