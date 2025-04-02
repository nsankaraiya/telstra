variable "vpc_cidr" {
  type        = string
  description = "Subnet allocation for VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "Public Subnet CIDR"
}

variable "private_subnet_cidr" {
  type        = string
  description = "Private Subnet CIDR"
}

variable "supported_regions" {
  type        = list(string)
  description = "Region where resources can be enabled"
  default     = ["ap-southeast-2"]
}

# Tags are key to ensure billing and budgeting can be done for each business unit 

variable "tags" {
  type        = map(strings)
  description = "Cloud service resources tags must include cost_center at the minimum"
  validation {
    condition     = var.tags != null
    error_message = "Tags nust be provided"
  }
  validation {
    condition     = contains(keys(var.tags), "cost_center")
    error_message = "cost_center tag is mandatory and must be provided"
  }
}