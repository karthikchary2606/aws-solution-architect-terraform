# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = var.tags
}

# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.cluster_name}"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# Namespace for service discovery
resource "aws_service_discovery_private_dns_namespace" "ecs" {
  name = "ecs.internal"
  vpc  = data.aws_vpc.main.id

  tags = var.tags
}

# Data source to get default VPC
data "aws_vpc" "main" {
  default = true
}
