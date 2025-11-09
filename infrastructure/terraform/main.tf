module "vpc" {
  source       = "git::https://github.com/ronchese66/devops-lab.git//infrastructure/terraform/modules/vpc?ref=v1.2.2"
  project_name = var.project_name
}

module "eks" {
  source       = "git::https://github.com/ronchese66/devops-lab.git//infrastructure/terraform/modules/eks?ref=eks-v1.0.0"
  project_name = var.project_name
}

module "kms" {
  source       = "git::https://github.com/ronchese66/devops-lab.git//infrastructure/terraform/modules/kms?ref=kms-v1.0.0"
  project_name            = var.project_name
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days
}