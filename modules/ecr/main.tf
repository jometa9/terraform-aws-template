resource "aws_ecr_repository" "repository" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability

  # Optional encryption configuration
  encryption_configuration {
    encryption_type = var.encryption_type
  }

  tags = {
    Name        = var.repository_name
    Environment = var.environment_name
  }
}
