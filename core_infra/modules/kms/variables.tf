

variable "name" {
  description = "The name of the kms key"
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "The name of the kms key prefix"
  type        = string
  default     = null
}

variable "kms_description" {
  description = "Description of kms key"
  type        = string
  default     = "Resource type based KMS Key"
}

variable "enable_multi_region" {
  description = "Set to true if bucket versioning needs to be enabled"
  type        = bool
  default     = true
}

variable "enable_key_rotation" {
  description = "Set to true if bucket versioning needs to be enabled"
  type        = bool
  default     = false
}

variable "is_key_enabled" {
  description = "Set to true if bucket versioning needs to be enabled"
  type        = bool
}

variable "kms_deletion_window" {
  description = "Number of days retain kms key after deletion"
  type        = number
  default     = 30
}

variable "policy_statements" {
  type        = any
  description = "List of user defined policy statements to add to bucket policy"
  default     = null
}


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