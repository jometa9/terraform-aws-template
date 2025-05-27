resource "aws_security_group" "database_sg" {
  name        = "${var.environment_name}-database-sg"
  description = "Security group for MySQL database"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.publicly_accessible ? ["0.0.0.0/0"] : ["10.100.0.0/16"]
    description = "Allow MySQL connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_name}-database-sg"
  }
}

resource "aws_db_subnet_group" "database" {
  name       = "${var.environment_name}-db-subnet-group"
  subnet_ids = var.subnet_ids
  
  tags = {
    Name = "${var.environment_name}-db-subnet-group"
  }
}

resource "aws_db_instance" "mysql_instance" {
  identifier             = "${var.environment_name}-mysql-instance"
  engine                 = "mysql"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.database.name
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  port                   = var.db_port
  
  # Storage configuration
  storage_type          = var.storage_type
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id
  
  # Network configuration
  publicly_accessible   = var.publicly_accessible
  
  # Performance configuration
  performance_insights_enabled = var.performance_insights_enabled
  monitoring_interval          = var.monitoring_interval
  
  # Maintenance and backup
  backup_retention_period = 7
  skip_final_snapshot     = true
  parameter_group_name    = aws_db_parameter_group.mysql_parameter_group.name
  
  tags = {
    Name = "${var.environment_name}-mysql-instance"
  }
}


# Create a DB parameter group for MySQL Community
resource "aws_db_parameter_group" "mysql_parameter_group" {
  name        = "${var.environment_name}-mysql-pg"
  family      = "mysql8.0"
  description = "Parameter group for MySQL Community"
  
  tags = {
    Name = "${var.environment_name}-mysql-pg"
  }
}
