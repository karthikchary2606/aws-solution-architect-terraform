variable "vpc_cidr" {
  type = string
}

variable "app_subnet_cidr" {
  type = string
}

variable "db_subnet_1_cidr" {
  type = string
}

variable "db_subnet_2_cidr" {
  type = string
}

variable "alb_subnet_1_cidr" {
  type = string
}

variable "alb_subnet_2_cidr" {
  type = string
}

variable "aws_region" {
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
