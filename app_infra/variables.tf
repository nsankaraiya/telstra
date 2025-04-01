# ALB  Variables
variable "vpc_id" {}

variable "branch" {
  description = "Name of the branch passed from Pipeline"
  type = string
}

variable "appname" {
  description = "Application Name"
  type = string
}

variable "cert_arn" {
  description = "ARN of SSL Certificate for ALB"
  type = string
}

variable "logs_bucket" {
  description = "Name of Logging S3 bucket"
  type = string
}

# EC2 Instance Variables

variable "custom_ami_id" {
  description = "Custom AMI ID for EC2 instances"
  type        = string
}

# ASG Specific Variables

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 10
}

variable "desired_capacity" {
  description = "Desired capacity for the ASG"
  type        = number
  default     = 5
}

variable "instance_type" {
  description = "Instance Type for Compute Engine"
  type        = string
  default   =  "t2.large"
}

