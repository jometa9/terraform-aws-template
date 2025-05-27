provider "aws" {
  region = var.aws_region
}

# VPC Configuration - Only created if enabled
module "vpc" {
  source = "./modules/vpc"
  count  = var.enable_vpc ? 1 : 0
  
  environment_name     = var.environment_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_1_cidr = var.public_subnet_1_cidr
  public_subnet_2_cidr = var.public_subnet_2_cidr
}

# IAM Roles - Required for ECS tasks, only created if ECS is enabled
module "iam" {
  source = "./modules/iam"
  count  = var.enable_ecs ? 1 : 0
  
  environment_name = var.environment_name
}

# ECS Cluster with simple container and autoscaling - Only created if enabled
module "ecs" {
  source = "./modules/ecs"
  count  = var.enable_ecs ? 1 : 0
  
  environment_name   = var.environment_name
  vpc_id             = var.enable_vpc ? module.vpc[0].vpc_id : ""
  public_subnet_1_id = var.enable_vpc ? module.vpc[0].public_subnet_1_id : ""
  public_subnet_2_id = var.enable_vpc ? module.vpc[0].public_subnet_2_id : ""
  certificate_arn    = var.certificate_arn
  app_name           = var.app_name
  
  # Container configuration
  container_image    = var.enable_ecr ? "${module.ecr[0].repository_url}:latest" : var.backend_image_url
  container_port     = var.backend_container_port
  container_cpu      = var.backend_container_cpu      # 256 = 0.25 vCPU
  container_memory   = var.backend_container_memory   # 512MB

  environment_variables = var.environment_variables
  
  # Autoscaling configuration
  desired_count      = var.backend_desired_count
  min_count          = var.backend_min_containers
  max_count          = var.backend_max_containers
  cpu_threshold      = var.backend_autoscaling_target_value
  http_health_check_path = var.backend_healthcheck_path
}

# ECR Repository for Docker images - Only created if enabled
module "ecr" {
  source = "./modules/ecr"
  count  = var.enable_ecr ? 1 : 0
  
  environment_name      = var.environment_name
  repository_name       = var.ecr_repository_name
  image_tag_mutability  = var.ecr_image_tag_mutability
  encryption_type       = var.ecr_encryption_type
}

# Database - Only created if enabled
module "database" {
  source = "./modules/database"
  count  = var.enable_rds ? 1 : 0
  
  environment_name = var.environment_name
  vpc_id           = module.vpc[0].vpc_id
  subnet_ids       = [module.vpc[0].public_subnet_1_id, module.vpc[0].public_subnet_2_id]
  db_name          = var.db_name
  db_username      = var.db_username
  db_password      = var.db_password
  db_engine_version = var.db_engine_version
  db_instance_class = var.db_instance_class
  db_port          = var.db_port
  publicly_accessible = var.publicly_accessible
  storage_type      = var.storage_type
  allocated_storage = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted = var.storage_encrypted
  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval = var.monitoring_interval
}

# S3 Storage - Only created if enabled
module "storage" {
  source = "./modules/storage"
  count  = var.enable_s3_storage ? 1 : 0
  
  environment_name = var.environment_name
  bucket_name      = var.storage_bucket_name
}

# Frontend - Only created if enabled
module "frontend" {
  source = "./modules/frontend"
  count  = var.enable_frontend ? 1 : 0
  
  environment_name = var.environment_name
  bucket_name      = var.frontend_bucket_name
  enable_cloudfront = var.frontend_enable_cloudfront
  domain_name       = var.frontend_domain_name
}

