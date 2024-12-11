variable "aws_region" {
  description = "The AWS Region"
  type        = string
}

variable "bucket_name" {
  description = "Bucket that stores terraform state"
  type        = string
}

variable "master_username" {
  description = "Username for the Master User of Aurora DB"
  type        = string
}

variable "master_password" {
  description = "Password for the Master User of Aurora DB"
  type        = string
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR value"
}

variable "public_subnets_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "private_subnets_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
}
