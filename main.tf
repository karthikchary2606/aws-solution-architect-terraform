locals {
  app_name = "${var.project_name}-${var.environment}"
  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

module "vpc" {
  count  = var.enable_services.vpc ? 1 : 0
  source = "./modules/vpc"

  vpc_cidr               = var.vpc_cidr
  app_subnet_cidr        = var.app_subnet_cidr
  db_subnet_1_cidr       = var.db_subnet_1_cidr
  db_subnet_2_cidr       = var.db_subnet_2_cidr
  alb_subnet_1_cidr      = var.alb_subnet_1_cidr
  alb_subnet_2_cidr      = var.alb_subnet_2_cidr
  aws_region             = var.aws_region
  project_name           = var.project_name
  environment            = var.environment

  tags = local.tags
}

module "rds" {
  count  = var.enable_services.rds ? 1 : 0
  source = "./modules/rds"

  db_identifier            = local.app_name
  db_name                  = var.db_name
  db_username              = var.db_user
  db_password              = var.db_password
  db_instance_class        = var.db_instance_class
  db_engine_version        = var.db_engine_version
  db_allocated_storage     = var.db_allocated_storage
  db_backup_retention_days = var.db_backup_retention_days
  enable_multi_az          = var.enable_multi_az

  vpc_id                   = module.vpc[0].vpc_id
  db_subnet_group_name     = module.vpc[0].db_subnet_group_name
  db_security_group_id     = module.vpc[0].db_security_group_id

  project_name = var.project_name
  environment  = var.environment

  tags = local.tags

  depends_on = [module.vpc]
}

module "ec2" {
  count  = var.enable_services.ec2 ? 1 : 0
  source = "./modules/ec2"

  instance_name     = "${local.app_name}-server"
  instance_type     = var.instance_type
  key_pair_name     = var.key_pair_name
  volume_size       = var.ec2_volume_size

  vpc_id               = module.vpc[0].vpc_id
  subnet_id            = module.vpc[0].app_subnet_id
  security_group_id    = module.vpc[0].app_security_group_id

  docker_image_uri  = var.docker_image_uri
  container_port    = var.container_port
  db_host           = var.enable_services.rds ? module.rds[0].endpoint : "localhost"
  db_name           = var.db_name
  db_username       = var.db_user
  db_password       = var.db_password
  jwt_secret        = var.jwt_secret

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  tags = local.tags

  depends_on = [module.vpc, module.rds]
}

module "alb" {
  count  = var.enable_services.alb ? 1 : 0
  source = "./modules/alb"

  alb_name              = "${local.app_name}-alb"
  vpc_id                = module.vpc[0].vpc_id
  alb_subnet_ids        = [module.vpc[0].alb_subnet_1_id, module.vpc[0].alb_subnet_2_id]
  alb_security_group_id = module.vpc[0].alb_security_group_id

  target_instance_id    = var.enable_services.ec2 ? module.ec2[0].instance_id : ""
  target_port           = var.container_port

  project_name = var.project_name
  environment  = var.environment

  tags = local.tags

  depends_on = [module.vpc, module.ec2]
}

module "monitoring" {
  count  = var.enable_services.monitoring ? 1 : 0
  source = "./modules/monitoring"

  alb_name           = var.enable_services.alb ? module.alb[0].alb_name : "none"
  instance_id        = var.enable_services.ec2 ? module.ec2[0].instance_id : "none"
  db_instance_id     = var.enable_services.rds ? module.rds[0].db_instance_id : "none"
  target_group_arn   = var.enable_services.alb ? module.alb[0].target_group_arn : "none"

  project_name = var.project_name
  environment  = var.environment

  tags = local.tags

  depends_on = [module.alb, module.ec2, module.rds]
}

# Security Module (Week 5)
module "security" {
  source = "./modules/security"

  project_name            = var.project_name
  environment             = var.environment
  enable_kms_encryption   = true
  enable_cloudtrail       = true
  cloudtrail_s3_bucket    = ""
  db_password             = var.db_password
  jwt_secret              = var.jwt_secret
  secrets_rotation_days   = 30

  tags = local.tags
}

# ECS Module (Week 2)
module "ecs" {
  count  = var.enable_services.ecs ? 1 : 0
  source = "./modules/ecs"

  cluster_name                 = "${local.app_name}-cluster"
  environment                  = var.environment
  enable_container_insights    = true
  log_retention_days           = 7

  tags = local.tags
}

# ElastiCache Module (Week 4)
module "elasticache" {
  count  = var.enable_services.elasticache ? 1 : 0
  source = "./modules/elasticache"

  cluster_id                = "${local.app_name}-cache"
  engine                    = "redis"
  engine_version            = "7.0"
  node_type                 = "cache.t3.micro"
  num_cache_nodes           = 1
  parameter_group_family    = "redis7"
  port                      = 6379

  subnet_ids              = var.enable_services.vpc ? [module.vpc[0].app_subnet_id] : []
  security_group_id       = var.enable_services.vpc ? module.vpc[0].app_security_group_id : ""
  vpc_id                  = var.enable_services.vpc ? module.vpc[0].vpc_id : ""

  automatic_failover_enabled = false
  multi_az_enabled           = false
  snapshot_retention_limit   = 5
  snapshot_window            = "03:00-05:00"
  maintenance_window         = "sun:05:00-sun:07:00"

  project_name = var.project_name
  environment  = var.environment

  tags = local.tags

  depends_on = [module.vpc]
}