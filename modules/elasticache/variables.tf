variable "cluster_id" {
  description = "ElastiCache cluster ID"
  type        = string
}

variable "engine" {
  description = "Cache engine (redis or memcached)"
  type        = string
  default     = "redis"
}

variable "engine_version" {
  description = "Cache engine version"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "Number of cache nodes"
  type        = number
  default     = 1
}

variable "parameter_group_family" {
  description = "ElastiCache parameter group family"
  type        = string
  default     = "redis7"
}

variable "port" {
  description = "Port for cache"
  type        = number
  default     = 6379
}

variable "subnet_ids" {
  description = "Subnet IDs for ElastiCache cluster"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ElastiCache"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "enable_automatic_failover" {
  description = "Enable automatic failover for Redis"
  type        = bool
  default     = false
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover (legacy parameter)"
  type        = bool
  default     = false
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ"
  type        = bool
  default     = false
}

variable "snapshot_retention_limit" {
  description = "Snapshot retention limit in days"
  type        = number
  default     = 5
}

variable "snapshot_window" {
  description = "Daily snapshot window (UTC)"
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "sun:05:00-sun:07:00"
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}
