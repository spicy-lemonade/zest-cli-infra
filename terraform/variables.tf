variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "nl-cli"
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "europe-west1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "bucket_suffix" {
  description = "Optional suffix for bucket name uniqueness (leave empty for auto-generated)"
  type        = string
  default     = ""
}

variable "data_retention_days" {
  description = "Number of days to retain data before lifecycle deletion (0 = no deletion)"
  type        = number
  default     = 0
}

variable "enable_versioning" {
  description = "Enable object versioning on the bucket"
  type        = bool
  default     = true
}
