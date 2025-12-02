variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name to be used for resource naming"
  type        = string
  default     = "cloudfinal"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "192.168.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "192.168.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "192.168.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1 (application)"
  type        = string
  default     = "192.168.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2 (application)"
  type        = string
  default     = "192.168.4.0/24"
}

variable "private_subnet_3_cidr" {
  description = "CIDR block for private subnet 3 (database)"
  type        = string
  default     = "192.168.5.0/24"
}

variable "private_subnet_4_cidr" {
  description = "CIDR block for private subnet 4 (database)"
  type        = string
  default     = "192.168.6.0/24"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "webapp_db"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
  default     = "YourSecurePassword123!" # Change this in production
}

variable "db_table_name" {
  description = "Database table name"
  type        = string
  default     = "users"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "instance_type" {
  description = "EC2 instance type for application servers"
  type        = string
  default     = "t2.micro"
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 instances"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCzMlgKXBpiRPpqVG+7UnxIvKEMcG1K5mqC1JI5DJ33XS4z4Ptpas/wgyV6hQul3+bzn0tJ3vgAlq7Yzc3Z/qVVdvKmlVFqSYg6ujQ3Zy5pjIBG3FlUaA6gUa3u6gH2yiXIXZRdaIItD7qYIah76PKkdMj9W3xhB+0P2okpyw5OPieNTMl4pZoaxTVXmhS8j6c8p4EEgoui5JWTlOzbPQapIsmdd0UPaWJj45bM932r6/TLb3GLLYE/7EAiq0Y8rwNmQwu7L5t4t/YT7KyoY2VwX7hcBxRQlQCrVZLFvg5VJGZHF/Zh6sx4EnVTnrlBlYw6QYztxRWPzmkh0AqWsBbPVlBml0wvqqzORdcHLUAncAM5cEai1ggjuuu9P7oEupo00ZR/A+gGcz0WjzX886woOjeWx8a58WO4AifGhM0ufRvzfyt66rjxLxQfs8/39GxDaE3SwM2ZN1exHAG7XHe1k+XT9vplOUpLKPcTQry/Hl7tVAD2H9uDcHHbw63zFZjQA+ttQMeg9vSrKt7M+X3kQJYkJcMbizjewIj7/dsi0yfbyNB7ZpNiaIwuEZ3WEoGAgszQ4yjuPG9efFC58JI17TbpDhRWrS8Z/cGnm/RRvGCwXwZ4weYQBpAdyNsUMlOMbcW+AxbY01JueTT5UZWAgMKTg2LnAz9HrQJvsR1Plw== cloudfinal-aws-key"
}
