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


#S3 Bucket Variables

variable "bucket" {
  description = "The name of the bucket"
  type = string
  default = null
}

variable "bucket_prefix" {
  description = "The prefix of the bucket"
  type = string
  default = null
}

variable "force_destroy" {
  description = "true or false indicating if the objects in the bucket be delete when bucket is deleted"
  type = bool
  default = null
}


variable "policy_statements" {
  type = any 
  description = "List of user defined policy statements to add to bucket policy"
  default = null
}

variable "kms_master_key_id" {
  description = "The KMS Key id for Encryption"
  type = string

  validation {
    condition = var.kms_master_key_id != null
    error_message = "Encryption key must be provided."
  }
  
}

# S3 bucket versioning and lifecycle policy

variable "bucket_versioning_status" {
  description = "Set to true if bucket versioning needs to be enabled"
  type = bool
  default = false
}

variable "bucket_lifecycle_status" {
  description = "Set to true if bucket lifecycle policy needs to be enabled"
  type = bool
  default = false
}

variable "object_transition_to_standard_ia" {
  description = "Number of days to to move files to Standar IA storage"
  type = number
  default = 30
}

variable "object_transition_to_glacier" {
  description = "Number of days to to move files to Glacier storage"
  type = number
  default = 365
}