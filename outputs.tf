# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = var.enable_vpc ? module.vpc[0].vpc_id : null
}

output "public_subnet_1_id" {
  description = "The ID of the first public subnet"
  value       = var.enable_vpc ? module.vpc[0].public_subnet_1_id : null
}

output "public_subnet_2_id" {
  description = "The ID of the second public subnet"
  value       = var.enable_vpc ? module.vpc[0].public_subnet_2_id : null
}

# ECS Outputs
output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = var.enable_ecs ? module.ecs[0].cluster_name : null
}

output "container_security_group" {
  description = "The ID of the container security group"
  value       = var.enable_ecs ? module.ecs[0].container_security_group : null
}

output "load_balancer_dns" {
  description = "The DNS name of the load balancer"
  value       = var.enable_ecs ? module.ecs[0].load_balancer_dns : null
}

# ECR Repository Outputs
output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = var.enable_ecr ? module.ecr[0].repository_url : null
}

output "ecr_repository_arn" {
  description = "The ARN of the ECR repository"
  value       = var.enable_ecr ? module.ecr[0].repository_arn : null
}

# Database Outputs

output "database_endpoint" {
  description = "The endpoint of the database instance"
  value       = var.enable_rds ? module.database[0].db_endpoint : null
}

output "database_port" {
  description = "The port of the database instance"
  value       = var.enable_rds ? module.database[0].db_port : null
}

# Cloudfront Outputs

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = var.enable_cloudfront ? module.frontend[0].cloudfront_distribution_id : null
}

# Frontend Outputs

output "frontend_bucket_name" {
  description = "The name of the S3 bucket for the frontend"
  value       = var.enable_frontend ? module.frontend[0].bucket_name : null
}

output "frontend_website_endpoint" {
  description = "The website endpoint of the S3 bucket for the frontend"
  value       = var.enable_frontend ? module.frontend[0].website_endpoint : null
}

# Storage - S3 Outputs

output "storage_bucket_name" {
  description = "The name of the S3 bucket for storage"
  value       = var.enable_s3_storage ? module.storage[0].bucket_name : null
}

output "storage_bucket_arn" {
  description = "The ARN of the S3 bucket for storage"
  value       = var.enable_s3_storage ? module.storage[0].bucket_arn : null
}

