module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
}

module "kms" {
  source                  = "./modules/kms"
  project_name            = var.project_name
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days
}