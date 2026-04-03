variable "alb_name" {
  type = string
}

variable "instance_id" {
  type = string
}

variable "db_instance_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "tags" {
  type = map(string)
}
