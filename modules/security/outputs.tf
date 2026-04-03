output "kms_key_id" {
  description = "KMS key ID"
  value       = var.enable_kms_encryption ? aws_kms_key.main[0].id : null
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = var.enable_kms_encryption ? aws_kms_key.main[0].arn : null
}

output "db_password_secret_arn" {
  description = "Database password secret ARN"
  value       = aws_secretsmanager_secret.db_password.arn
  sensitive   = true
}

output "db_password_secret_name" {
  description = "Database password secret name"
  value       = aws_secretsmanager_secret.db_password.name
}

output "jwt_secret_arn" {
  description = "JWT secret ARN"
  value       = aws_secretsmanager_secret.jwt_secret.arn
  sensitive   = true
}

output "jwt_secret_name" {
  description = "JWT secret name"
  value       = aws_secretsmanager_secret.jwt_secret.name
}

output "cloudtrail_arn" {
  description = "CloudTrail ARN"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].arn : null
}

output "cloudtrail_s3_bucket" {
  description = "CloudTrail S3 bucket"
  value       = var.enable_cloudtrail && var.cloudtrail_s3_bucket == "" ? aws_s3_bucket.cloudtrail[0].id : var.cloudtrail_s3_bucket
}

output "cloudtrail_log_group_name" {
  description = "CloudTrail CloudWatch Log Group name"
  value       = var.enable_cloudtrail ? aws_cloudwatch_log_group.cloudtrail[0].name : null
}
