# General AWS Configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment_name" {
  description = "A name that will be used for namespacing all resources"
  type        = string
  default     = "prod"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "app"
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS"
  type        = string
  default     = ""
}

# Component Toggle Flags
variable "enable_vpc" {
  description = "Whether to deploy VPC resources"
  type        = bool
  default     = true
}

variable "enable_ecs" {
  description = "Whether to deploy ECS resources"
  type        = bool
  default     = true
}

variable "enable_rds" {
  description = "Whether to deploy RDS database resources"
  type        = bool
  default     = false
}

variable "enable_s3_storage" {
  description = "Whether to deploy S3 storage bucket"
  type        = bool
  default     = false
}

variable "enable_frontend" {
  description = "Whether to deploy frontend resources"
  type        = bool
  default     = false
}

variable "enable_cloudfront" {
  description = "Whether to enable CloudFront for the frontend"
  type        = bool
  default     = false
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.100.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for the first public subnet"
  type        = string
  default     = "10.100.0.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for the second public subnet"
  type        = string
  default     = "10.100.1.0/24"
}

# Database Configuration
variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_username" {
  description = "Username for the database"
  type        = string
}

variable "db_password" {
  description = "Password for the database"
  type        = string
  sensitive   = true
}

variable "db_engine_version" {
  description = "The version of the database engine"
  type        = string
  default     = "8.0.35"
}

variable "db_port" {
  description = "The port on which the database accepts connections"
  type        = number
  default     = 3306
}

variable "db_instance_class" {
  description = "The instance type for the database"
  type        = string
  default     = "db.t4g.micro"
}

variable "publicly_accessible" {
  description = "Whether the database should be publicly accessible"
  type        = bool
  default     = true
}

variable "storage_type" {
  description = "The storage type for the database (e.g., gp3)"
  type        = string
  default     = "gp3"
}

variable "allocated_storage" {
  description = "The amount of allocated storage for the database in GB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "The upper limit to which Amazon RDS can automatically scale the storage in GB"
  type        = number
  default     = 1000
}

variable "storage_encrypted" {
  description = "Whether the storage should be encrypted"
  type        = bool
  default     = true
}

variable "performance_insights_enabled" {
  description = "Whether Performance Insights is enabled"
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected. 0 to disable"
  type        = number
  default     = 0
}

# Storage Configuration
variable "storage_bucket_name" {
  description = "Name of the S3 bucket for application storage"
  type        = string
}

# Backend API Configuration
variable "backend_service_name" {
  description = "Name of the backend service"
  type        = string
  default     = "api-service"
}

variable "backend_image_url" {
  description = "URL of the Docker image for the backend"
  type        = string
}

variable "backend_container_port" {
  description = "Port number the application inside the docker container is binding to"
  type        = number
  default     = 8080
}

variable "backend_task_cpu" {
  description = "How much CPU to give the task. 1024 is 1 CPU"
  type        = number
  default     = 1024
}

variable "backend_container_cpu" {
  description = "How much CPU to give the container. 1024 is 1 CPU"
  type        = number
  default     = 1024
}

variable "backend_task_memory" {
  description = "How much memory in megabytes to give the task"
  type        = number
  default     = 2048
}

variable "backend_container_memory" {
  description = "How much memory in megabytes to give the container"
  type        = number
  default     = 2048
}

variable "backend_desired_count" {
  description = "How many copies of the service task to run"
  type        = number
  default     = 1
}

variable "backend_path_pattern" {
  description = "A path on the ALB balancer that this service should be connected to"
  type        = string
  default     = "/api/*"
}

variable "backend_healthcheck_path" {
  description = "Path for health check of the backend service"
  type        = string
  default     = "/api/v1/healthcheck"
}

variable "backend_min_containers" {
  description = "Minimum number of containers for autoscaling"
  type        = number
  default     = 1
}

variable "backend_max_containers" {
  description = "Maximum number of containers for autoscaling"
  type        = number
  default     = 5
}

variable "backend_autoscaling_target_value" {
  description = "Target value for autoscaling (CPU utilization percentage)"
  type        = number
  default     = 60
}

variable "backend_node_env" {
  description = "NODE_ENV environment variable for the backend"
  type        = string
  default     = "production"
}

variable "backend_timezone" {
  description = "Timezone for the backend"
  type        = string
  default     = "UTC"
}

variable "environment_variables" {
  description = "Environment variables for the backend service"
  type        = map(string)
  default     = null
}

# Frontend Configuration
variable "frontend_bucket_name" {
  description = "Name of the S3 bucket for frontend hosting"
  type        = string
}

variable "frontend_enable_cloudfront" {
  description = "Whether to enable CloudFront for the frontend"
  type        = bool
  default     = true
}

variable "frontend_domain_name" {
  description = "Domain name for the frontend"
  type        = string
  default     = ""
}

# ECR Configuration
variable "enable_ecr" {
  description = "Whether to deploy ECR repository"
  type        = bool
  default     = true
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "api-service"
}

variable "ecr_image_tag_mutability" {
  description = "The tag mutability setting for the repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_encryption_type" {
  description = "The encryption type to use for the repository (AES256 or KMS)"
  type        = string
  default     = "AES256"
}
