output "cluster_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.ecs.arn
}

output "service_discovery_namespace_id" {
  description = "Service discovery private DNS namespace ID"
  value       = aws_service_discovery_private_dns_namespace.ecs.id
}

output "service_discovery_namespace_arn" {
  description = "Service discovery private DNS namespace ARN"
  value       = aws_service_discovery_private_dns_namespace.ecs.arn
}
