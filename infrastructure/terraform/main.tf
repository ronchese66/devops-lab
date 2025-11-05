module "vpc" {
  source       = 
  source       = "git::https://github.com/ronchese66/devops-lab.git//infrastructure/terraform/modules/vpc?ref=v1.2.1"
  project_name = var.project_name
}