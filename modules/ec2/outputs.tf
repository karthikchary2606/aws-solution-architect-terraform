output "instance_id" {
  value = aws_instance.main.id
}

output "private_ip" {
  value = aws_instance.main.private_ip
}

output "public_ip" {
  value = aws_eip.ec2.public_ip
}

output "instance_arn" {
  value = aws_instance.main.arn
}
