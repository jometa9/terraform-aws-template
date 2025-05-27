output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "container_security_group" {
  description = "The ID of the container security group"
  value       = aws_security_group.ecs_containers.id
}

output "listener_arn" {
  description = "The ARN of the main listener"
  value       = var.certificate_arn != "" ? aws_lb_listener.https[0].arn : aws_lb_listener.http.arn
}

output "load_balancer_dns" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "private_namespace_id" {
  description = "The ID of the private service discovery namespace"
  value       = aws_service_discovery_private_dns_namespace.ecs.id
}
