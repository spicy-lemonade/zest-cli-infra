variable "project_id_dev" {
  description = "GCP project ID for dev environment"
  type        = string
  default     = "nl-cli-dev"
}

variable "project_id_prod" {
  description = "GCP project ID for prod environment"
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

variable "owner_email" {
  description = "Email address of the project owner"
  type        = string
  default     = "ciaranobrienmusic@gmail.com"
}

variable "ml_group_email" {
  description = "Google Group email for ML engineers"
  type        = string
  default     = "spicy-lemonage-nl-cli-ml-engineers@googlegroups.com"
}
