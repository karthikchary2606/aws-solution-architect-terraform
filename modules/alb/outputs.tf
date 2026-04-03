output "alb_arn" {
  value = aws_lb.main.arn
}

output "alb_name" {
  value = aws_lb.main.name
}

output "dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}

output "zone_id" {
  value = aws_lb.main.zone_id
}
