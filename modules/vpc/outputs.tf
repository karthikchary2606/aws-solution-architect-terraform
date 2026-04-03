output "vpc_id" {
  value = aws_vpc.main.id
}

output "app_subnet_id" {
  value = aws_subnet.app.id
}

output "alb_subnet_1_id" {
  value = aws_subnet.alb_1.id
}

output "alb_subnet_2_id" {
  value = aws_subnet.alb_2.id
}

output "db_subnet_ids" {
  value = [aws_subnet.db_1.id, aws_subnet.db_2.id]
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.main.name
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "app_security_group_id" {
  value = aws_security_group.app.id
}

output "db_security_group_id" {
  value = aws_security_group.db.id
}
