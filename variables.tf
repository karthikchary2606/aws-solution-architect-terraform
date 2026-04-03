variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "task-app"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_subnet_cidr" {
  description = "App subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "db_subnet_1_cidr" {
  description = "DB subnet 1 CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "db_subnet_2_cidr" {
  description = "DB subnet 2 CIDR"
  type        = string
  default     = "10.0.3.0/24"
}

variable "alb_subnet_1_cidr" {
  description = "ALB subnet 1 CIDR"
  type        = string
  default     = "10.0.4.0/24"
}

variable "alb_subnet_2_cidr" {
  description = "ALB subnet 2 CIDR"
  type        = string
  default     = "10.0.5.0/24"
}

# RDS Configuration
variable "db_engine_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "15.4"
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "taskdb"
}

variable "db_user" {
  description = "Database admin username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Database admin password"
  type        = string
  sensitive   = true
}

variable "db_backup_retention_days" {
  description = "Backup retention days"
  type        = number
  default     = 7
}

# EC2 Configuration
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3a.medium"
}

variable "key_pair_name" {
  description = "SSH key pair name"
  type        = string
  default     = "test-key"
}

variable "ec2_volume_size" {
  description = "Root volume size GB"
  type        = number
  default     = 30
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 8000
}

variable "docker_image_uri" {
  description = "Docker image URI"
  type        = string
  default     = "placeholder"
}

variable "jwt_secret" {
  description = "JWT secret key"
  type        = string
  sensitive   = true
  default     = "AbCdEfGhIjKlMnOpQrStUvWxYz1234567890"
}

# Features - Service Enable/Disable
variable "enable_services" {
  description = "Enable/disable AWS services"
  type = object({
    vpc        = bool
    rds        = bool
    ec2        = bool
    alb        = bool
    monitoring = bool
    ecs        = bool
    elasticache = bool
  })
  default = {
    vpc        = true
    rds        = true
    ec2        = true
    alb        = true
    monitoring = true
    ecs        = true
    elasticache = true
  }
}

variable "enable_multi_az" {
  description = "Enable Multi-AZ RDS"
  type        = bool
  default     = true
}