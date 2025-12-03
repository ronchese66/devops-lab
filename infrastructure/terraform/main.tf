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

module "sm" {
  source = "./modules/sm"
  project_name = var.project_name
  secrets_manager_key_arn = module.kms.secrets_manager_key_arn
}

module "ecs" {
  source = "./modules/ecs"
  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  cloudwatch_logs_key_arn = module.kms.cloudwatch_logs_key_arn
  db_password_secret_arn = module.sm.db_password_secret_arn
  secrets_manager_key_arn = module.kms.secrets_manager_key_arn
  efs_access_point_id = "LATER"
  efs_file_system_id = "LATER"
}