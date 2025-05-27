variable "environment_name" {
  description = "A name that will be used for namespacing all resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the database subnet group"
  type        = list(string)
}

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

variable "db_instance_class" {
  description = "The instance type for the database"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_port" {
  description = "The port on which the database accepts connections"
  type        = number
  default     = 3306
}

variable "publicly_accessible" {
  description = "Whether the database should be publicly accessible"
  type        = bool
  default     = false
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

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. If not specified, AWS managed KMS key is used"
  type        = string
  default     = null
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
