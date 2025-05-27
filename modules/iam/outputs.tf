output "autoscaling_role_arn" {
  description = "The ARN of the role used for autoscaling"
  value       = aws_iam_role.autoscaling.arn
}

output "ecs_role_arn" {
  description = "The ARN of the ECS role"
  value       = aws_iam_role.ecs.arn
}

output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "The ARN of the ECS task role"
  value       = aws_iam_role.ecs_task.arn
}
