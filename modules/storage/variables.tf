variable "environment_name" {
  description = "A name that will be used for namespacing our resources"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}
