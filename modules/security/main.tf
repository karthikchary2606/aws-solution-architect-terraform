# KMS Key for encryption
resource "aws_kms_key" "main" {
  count = var.enable_kms_encryption ? 1 : 0

  description             = "KMS key for ${var.project_name}-${var.environment}"
  deletion_window_in_days = var.kms_deletion_window_days
  enable_key_rotation     = var.enable_key_rotation

  tags = var.tags
}

resource "aws_kms_alias" "main" {
  count = var.enable_kms_encryption ? 1 : 0

  name          = "alias/${var.project_name}-${var.environment}"
  target_key_id = aws_kms_key.main[0].key_id
}

# Secrets Manager secret for database password
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project_name}/${var.environment}/db-password"
  recovery_window_in_days = 7
  kms_key_id              = var.enable_kms_encryption ? aws_kms_key.main[0].id : null

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id       = aws_secretsmanager_secret.db_password.id
  secret_string   = var.db_password
  version_stages = ["AWSCURRENT"]
}

# Note: Rotation requires a Lambda function for automatic rotation
# This is intentionally commented out. To enable, create a Lambda rotation function.
# resource "aws_secretsmanager_secret_rotation" "db_password" {
#   secret_id = aws_secretsmanager_secret.db_password.id
#
#   rotation_rules {
#     automatically_after_days = var.secrets_rotation_days
#   }
# }

# Secrets Manager secret for JWT
resource "aws_secretsmanager_secret" "jwt_secret" {
  name                    = "${var.project_name}/${var.environment}/jwt-secret"
  recovery_window_in_days = 7
  kms_key_id              = var.enable_kms_encryption ? aws_kms_key.main[0].id : null

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id       = aws_secretsmanager_secret.jwt_secret.id
  secret_string   = var.jwt_secret
  version_stages = ["AWSCURRENT"]
}

# Note: Rotation requires a Lambda function for automatic rotation
# This is intentionally commented out. To enable, create a Lambda rotation function.
# resource "aws_secretsmanager_secret_rotation" "jwt_secret" {
#   secret_id = aws_secretsmanager_secret.jwt_secret.id
#
#   rotation_rules {
#     automatically_after_days = var.secrets_rotation_days
#   }
# }

# CloudTrail for audit logging
resource "aws_cloudtrail" "main" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = "${var.project_name}-trail"
  s3_bucket_name                = var.cloudtrail_s3_bucket != "" ? var.cloudtrail_s3_bucket : aws_s3_bucket.cloudtrail[0].id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  depends_on                    = [aws_s3_bucket_policy.cloudtrail]

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::*"]
    }
  }

  tags = var.tags
}

# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail" {
  count = var.enable_cloudtrail && var.cloudtrail_s3_bucket == "" ? 1 : 0

  bucket = "${var.project_name}-cloudtrail-${data.aws_caller_identity.current.account_id}"

  tags = var.tags
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  count = var.enable_cloudtrail && var.cloudtrail_s3_bucket == "" ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count = var.enable_cloudtrail && var.cloudtrail_s3_bucket == "" ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count = var.enable_cloudtrail && var.cloudtrail_s3_bucket == "" ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count = var.enable_cloudtrail && var.cloudtrail_s3_bucket == "" ? 1 : 0

  bucket = aws_s3_bucket.cloudtrail[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail[0].arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail[0].arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudWatch Log Group for CloudTrail
resource "aws_cloudwatch_log_group" "cloudtrail" {
  count = var.enable_cloudtrail ? 1 : 0

  name              = "/aws/cloudtrail/${var.project_name}"
  retention_in_days = 7

  tags = var.tags
}

# CloudWatch Logs IAM role for CloudTrail
resource "aws_iam_role" "cloudtrail_cloudwatch_logs" {
  count = var.enable_cloudtrail ? 1 : 0

  name = "${var.project_name}-cloudtrail-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch_logs" {
  count = var.enable_cloudtrail ? 1 : 0

  name = "${var.project_name}-cloudtrail-logs-policy"
  role = aws_iam_role.cloudtrail_cloudwatch_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.cloudtrail[0].arn}:*"
      }
    ]
  })
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}
