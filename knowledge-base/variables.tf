
# Environment variable for deployment environment (e.g. dev, staging, prod)
variable "environment" {
  description = "Deployment environment"
  type        = string
}

# AWS region variable
variable "region_name" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

# SID variable for unique identifier
variable "sid" {
  description = "Unique identifier/SID"
  type        = string
}