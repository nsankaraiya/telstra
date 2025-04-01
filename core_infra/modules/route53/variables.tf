variable "comment" {
  type = string
  description = "Purpose of Hosted Zone"
  default = null
}


variable "name" {
  type = string
  description = "The name of hosted zone"
}

variable "vpc" {
  type = object({
    vpc_id = string
    vpc_region = string
  })
  description = "VPC details for Private Hosted Zone"
  default = null
}

# Tags are key to ensure billing and budgeting can be done for each business unit 

variable "tags" {
  type = map(strings)
  description = "Cloud service resources tags must include cost_center at the minimum"
  validation {
    condition = var.tags != null
    error_message = "Tags nust be provided"
  }
  validation {
    condition = contains(keys(var.tags), "cost_center")
    error_message = "cost_center tag is mandatory and must be provided"
  }
}