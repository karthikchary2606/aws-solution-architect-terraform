output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = var.enable_services.alb ? module.alb[0].dns_name : null
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = var.enable_services.alb ? module.alb[0].alb_arn : null
}

output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = var.enable_services.rds ? module.rds[0].endpoint : null
  sensitive   = true
}

output "rds_instance_id" {
  description = "RDS instance ID"
  value       = var.enable_services.rds ? module.rds[0].db_instance_id : null
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = var.enable_services.ec2 ? module.ec2[0].instance_id : null
}

output "ec2_public_ip" {
  description = "EC2 public IP address (Elastic IP)"
  value       = var.enable_services.ec2 ? module.ec2[0].public_ip : null
}

output "ec2_private_ip" {
  description = "EC2 private IP address"
  value       = var.enable_services.ec2 ? module.ec2[0].private_ip : null
}

output "vpc_id" {
  description = "VPC ID"
  value       = var.enable_services.vpc ? module.vpc[0].vpc_id : null
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = var.enable_services.monitoring ? module.monitoring[0].dashboard_url : null
}

output "ssh_connection_command" {
  description = "SSH connection command"
  value       = var.enable_services.ec2 ? "ssh -i /path/to/key.pem ec2-user@${module.ec2[0].public_ip}" : null
}

output "application_url" {
  description = "Application URL via ALB"
  value       = var.enable_services.alb ? "http://${module.alb[0].dns_name}" : null
}

# Service status outputs
output "enabled_services" {
  description = "Status of enabled services"
  value = {
    vpc        = var.enable_services.vpc
    rds        = var.enable_services.rds
    ec2        = var.enable_services.ec2
    alb        = var.enable_services.alb
    monitoring = var.enable_services.monitoring
  }
}
