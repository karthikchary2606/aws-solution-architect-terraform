variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "enable_kms_encryption" {
  description = "Enable KMS encryption"
  type        = bool
  default     = true
}

variable "kms_deletion_window_days" {
  description = "KMS key deletion window (days)"
  type        = number
  default     = 30
}

variable "enable_key_rotation" {
  description = "Enable KMS key rotation"
  type        = bool
  default     = true
}

variable "db_password" {
  description = "Database password to store in Secrets Manager"
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "JWT secret to store in Secrets Manager"
  type        = string
  sensitive   = true
}

variable "secrets_rotation_days" {
  description = "Rotation period for secrets (days)"
  type        = number
  default     = 30
}

variable "enable_cloudtrail" {
  description = "Enable CloudTrail logging"
  type        = bool
  default     = true
}

variable "cloudtrail_s3_bucket" {
  description = "S3 bucket for CloudTrail logs"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
