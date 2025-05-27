# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.environment_name}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  
  tags = {
    Name = "${var.environment_name}-cluster"
  }
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

# Load Balancer
resource "aws_lb" "main" {
  name               = "${var.environment_name}-cluster-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = [var.public_subnet_1_id, var.public_subnet_2_id]
  
  enable_deletion_protection = false
  
  idle_timeout = 30
  
  tags = {
    Name = "${var.environment_name}-cluster-ALB"
  }
}

# Load Balancer Listener (HTTPS or HTTP based on certificate_arn)
resource "aws_lb_listener" "https" {
  count = var.certificate_arn != "" ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn
  
  # Prevent Terraform from modifying manually created certificate
  lifecycle {
    ignore_changes = [
      certificate_arn,
      default_action
    ]
  }
  
  default_action {
    type = "redirect"
    
    redirect {
      port        = "#{port}"
      protocol    = "#{protocol}"
      host        = "#{host}"
      path        = "/"
      status_code = "HTTP_301"
    }
  }
}

# Load Balancer Listener (HTTP - either redirect to HTTPS or primary listener)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type = var.certificate_arn != "" ? "redirect" : "forward"
    
    dynamic "redirect" {
      for_each = var.certificate_arn != "" ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        host        = "#{host}"
        path        = "/#{path}"
        query       = "#{query}"
        status_code = "HTTP_301"
      }
    }
    
    # Use the default target group if no certificate is provided
    target_group_arn = var.certificate_arn == "" ? aws_lb_target_group.app_tg.arn : null
  }
}

# Default Target Group
resource "aws_lb_target_group" "default" {
  name     = "${var.environment_name}-default"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
  
  lifecycle {
    create_before_destroy = true
  }
}

# CloudWatch Logs Group
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "${var.environment_name}-apis"
  retention_in_days = 1
}

# Security Groups
resource "aws_security_group" "lb" {
  name        = "${var.environment_name}-cluster-security"
  description = "Security group for loadbalancer to services on ECS"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_containers" {
  name        = "${var.environment_name}-ecs-container-sg"
  description = "Access to the ECS hosts that run containers"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.lb.id]
  }
  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.100.0.0/16"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# IAM - ECS Task Execution Role
resource "aws_iam_role" "ecs_execution" {
  name = "${var.environment_name}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM - ECS Task Role
resource "aws_iam_role" "ecs_task" {
  name = "${var.environment_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Service Discovery
resource "aws_service_discovery_private_dns_namespace" "ecs" {
  name        = "ecs.${var.environment_name}"
  description = "Private DNS namespace for ECS services"
  vpc         = var.vpc_id
}

# Target group for the service
resource "aws_lb_target_group" "app_tg" {
  name                 = "${var.environment_name}-${var.app_name}-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 30
  
  health_check {
    enabled             = true
    interval            = 30
    path                = var.http_health_check_path
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200-299"
  }
}

# Path-based routing for the service (only for HTTPS listener)
resource "aws_lb_listener_rule" "app_rule" {
  count = var.certificate_arn != "" ? 1 : 0
  
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 100
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
  
  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

# Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "${var.environment_name}-${var.app_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn
  # Prevent Terraform from modifying environment variables that were manually added
  # lifecycle {
  #   ignore_changes = [
  #     #container_definitions,
  #     #ephemeral_storage,
  #     #runtime_platform
  #   ]
  # }

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture       = "ARM64"
  }
  
  container_definitions = jsonencode([
    {
      name         = var.app_name
      image        = var.container_image
      essential    = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = var.environment_variables != null ? [
        for key, value in var.environment_variables : {
          name  = key
          value = tostring(value)
        }
      ] : []
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = var.app_name
        }
      }
    }
  ])
}

# Service
resource "aws_ecs_service" "app" {
  name                               = var.app_name
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.app.arn
  desired_count                      = var.desired_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"
  platform_version                   = "LATEST"
    # Prevent Terraform from trying to update various service components
  # lifecycle {
  #   ignore_changes = [
  #     task_definition,
  #     load_balancer,
  #     desired_count
  #   ]
  # }
  
  network_configuration {
    security_groups  = [aws_security_group.ecs_containers.id]
    subnets          = [var.public_subnet_1_id, var.public_subnet_2_id]
    assign_public_ip = true
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = var.app_name
    container_port   = var.container_port
  }

  service_registries {
    registry_arn = aws_service_discovery_service.app.arn
  }
}

# Service Discovery Service
resource "aws_service_discovery_service" "app" {
  name = var.app_name
  
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ecs.id
    
    dns_records {
      ttl  = 10
      type = "A"
    }
    
    routing_policy = "MULTIVALUE"
  }
  
  health_check_custom_config {
    failure_threshold = 1
  }
}

# Autoscaling
resource "aws_appautoscaling_target" "app" {
  max_capacity       = var.max_count
  min_capacity       = var.min_count
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU-based Autoscaling Policy
resource "aws_appautoscaling_policy" "app_cpu" {
  name               = "${var.app_name}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.app.resource_id
  scalable_dimension = aws_appautoscaling_target.app.scalable_dimension
  service_namespace  = aws_appautoscaling_target.app.service_namespace
  
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    
    target_value       = var.cpu_threshold
    scale_in_cooldown  = 300
    scale_out_cooldown = 60
  }
}
