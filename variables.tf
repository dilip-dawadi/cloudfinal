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
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXHt7p50T1iWSD+Y/8OPxgdVuXEg2/aYyKy4qeQmQfEnBbSuM4Oe8YVWIBh+uBFPUpREfZivhxDhfPtjGwZUf/EEwCGXHrQMHzOPivlXrqE7hX6P8tITA2Xavfcwa7n2tanXjdhyHvWdo8chqsdixDHNBJV+mX+tA5ak2r5zRaNDt+PbRVZ12UT6Z3LKngFLB/u59wXOXEElmvcGg1/K98H6OubBvBB5YU26Et2dcCK3+6ZJyc8E6KSBRjFXmHYuiFB2bsTcU2rJZ/+O71WLB0X5rVfMYOEnZosU+o5pe/gR5LP+QPKWj8HYjlfj+jlIc9dyrJsHmH5Qap3P9Y5zUN9DGTVFaK+c8qJtt5f0JQVwlK3SlkRl+uyE20qjv9u0Ko2Yj0RdK+Bq2A9a+M1ubVvR4RGssJ5EHtAay4nqoNiypz9ydO9pcE74QzXnK0a9UiAs9QV3V28ibfYKey45WY4N4oFQ9sEYy7zCwoK5gMSSFEBDKkLcZIz4hyaHZ3uAnv7uHUhseewnC7zKZdmrADPekvLzRQyPqoKXNkB66PObAbXMcfA4Fg1ehMUe7gEEjmZND3CJmXYJ2z2u2THELy5b4Xr/V6Z7sXGkhY/P65ONTbqbOv/vgxxEKOOSu7dn0rJrzRglH3BqHaB+B2SzO3lOmbQjEHfT0atNVXdf07Zw== dilipdawadi@Dilips-MacBook-Pro.local"
  # IMPORTANT: Replace this with your actual SSH public key before deploying
}
