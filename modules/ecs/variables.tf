variable "environment_name" {
  description = "A name that will be used for namespacing our resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "public_subnet_1_id" {
  description = "The ID of the first public subnet"
  type        = string
}

variable "public_subnet_2_id" {
  description = "The ID of the second public subnet"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS"
  type        = string
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "app"
}

variable "container_image" {
  description = "Docker image for the service"
  type        = string
  default     = "nginx:latest"
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 80
}

variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory limit for the container in MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Desired number of containers"
  type        = number
  default     = 1
}

variable "min_count" {
  description = "Minimum number of containers"
  type        = number
  default     = 1
}

variable "max_count" {
  description = "Maximum number of containers"
  type        = number
  default     = 10
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for scaling"
  type        = number
  default     = 75
}

variable "http_health_check_path" {
  description = "Path for health check"
  type        = string
  default     = "/"
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}