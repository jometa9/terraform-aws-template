variable "environment_name" {
  description = "A name that will be used for namespacing all resources"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket for frontend hosting"
  type        = string
}

variable "enable_frontend" {
  description = "Whether to enable CloudFront for the frontend"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Domain name for the frontend"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS"
  type        = string
  default     = ""
}

variable "enable_cloudfront" {
  description = "Whether to enable CloudFront for the frontend"
  type        = bool
  default     = true
}