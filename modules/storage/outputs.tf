output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.storage.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.storage.arn
}

output "bucket_domain_name" {
  description = "The domain name of the S3 bucket"
  value       = aws_s3_bucket.storage.bucket_domain_name
}
