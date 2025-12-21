module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
}

module "kms" {
  source                             = "./modules/kms"
  project_name                       = var.project_name
  enable_key_rotation                = var.enable_key_rotation
  sm_deletion_window_in_days         = var.sm_deletion_window_in_days
  cloudwatch_deletion_window_in_days = var.cloudwatch_deletion_window_in_days
  efs_deletion_window_in_days        = var.efs_deletion_window_in_days
  rds_deletion_window_in_days = var.rds_deletion_window_in_days
}

module "sm" {
  source                  = "./modules/sm"
  project_name            = var.project_name
  secrets_manager_key_arn = module.kms.secrets_manager_key_arn
}

module "ecs" {
  source                  = "./modules/ecs"
  project_name            = var.project_name
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  cloudwatch_logs_key_arn = module.kms.cloudwatch_logs_key_arn
  db_password_secret_arn  = module.sm.db_password_secret_arn
  secrets_manager_key_arn = module.kms.secrets_manager_key_arn
  efs_access_point_id     = module.efs.efs_access_point_id
  efs_access_point_arn    = module.efs.efs_access_point_arn
  efs_file_system_id      = module.efs.efs_file_system_id
  efs_file_system_arn     = module.efs.efs_file_system_arn
  efs_mount_target_sg_id  = module.efs.efs_mount_target_sg_id
  rds_sg_id = module.rds.rds_sg_id
  redis_sg = module.elasticache.redis_sg_id
}

module "rds" {
  source = "./modules/rds"
  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  ecs_app_sg_id = module.ecs.ecs_app_sg_id
  vpc_cidr = module.vpc.vpc_cidr
  private_subnet_ids = module.vpc.private_subnet_ids
  db_password_value = module.sm.db_password_value
  rds_key_arn = module.kms.rds_key_arn
  rds_backup_retention_period = var.rds_backup_retention_period
  rds_preferred_backup_window = var.rds_preferred_backup_window
  rds_preferred_maintenance_window = var.rds_preferred_maintenance_window
  cloudwatch_logs_key_arn = module.kms.cloudwatch_logs_key_arn
}

module "efs" {
  source             = "./modules/efs"
  project_name       = var.project_name
  efs_key_arn        = module.kms.efs_key_arn
  private_subnet_ids = module.vpc.private_subnet_ids
  vpc_id             = module.vpc.vpc_id
  ecs_app_sg_id      = module.ecs.ecs_app_sg_id
}

module "elasticache" {
  source = "./modules/elasticache"
  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  ecs_app_sg_id = module.ecs.ecs_app_sg_id
  private_subnet_ids = module.vpc.private_subnet_ids
  redis_maintenance_window = var.redis_maintenance_window
  cloudwatch_logs_key_arn = module.kms.cloudwatch_logs_key_arn
}

module "datasync" {
  source                  = "./modules/datasync"
  project_name            = var.project_name
  efs_file_system_arn     = module.efs.efs_file_system_arn
  efs_mount_target_sg_arn = module.efs.efs_mount_target_sg_arn
  private_subnet_arns     = module.vpc.private_subnet_arns
  backup_schedule         = var.backup_schedule
  notification_email      = var.notification_email
}

module "route53-internal" {
  source = "./modules/route53-internal"
  project_name = var.project_name
  vpc_id = module.vpc.vpc_id
  dns_ttl = var.dns_ttl
  rds_cluster_endpoint = module.rds.rds_cluster_endpoint
  redis_prim_endpoint = module.elasticache.redis_prim_endpoint
}

