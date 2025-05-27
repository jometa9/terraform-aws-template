output "db_endpoint" {
  description = "The endpoint of the database"
  value       = aws_db_instance.mysql_instance.endpoint
}

output "db_port" {
  description = "The port of the database"
  value       = aws_db_instance.mysql_instance.port
}

output "db_name" {
  description = "The name of the database"
  value       = aws_db_instance.mysql_instance.db_name
}

output "db_security_group_id" {
  description = "The ID of the database security group"
  value       = aws_security_group.database_sg.id
}
