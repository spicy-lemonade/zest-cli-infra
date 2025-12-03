output "base_bucket_name" {
  description = "Name of the base layer storage bucket"
  value       = google_storage_bucket.nlcli_ml_training_base.name
}

output "base_bucket_url" {
  description = "GCS URL of the base layer bucket"
  value       = google_storage_bucket.nlcli_ml_training_base.url
}

output "base_bucket_self_link" {
  description = "Self link of the base bucket for IAM bindings"
  value       = google_storage_bucket.nlcli_ml_training_base.self_link
}

output "staging_bucket_name" {
  description = "Name of the staging layer storage bucket"
  value       = google_storage_bucket.nlcli_ml_training_staging.name
}

output "staging_bucket_url" {
  description = "GCS URL of the staging layer bucket"
  value       = google_storage_bucket.nlcli_ml_training_staging.url
}

output "staging_bucket_self_link" {
  description = "Self link of the staging bucket for IAM bindings"
  value       = google_storage_bucket.nlcli_ml_training_staging.self_link
}

output "mart_bucket_name" {
  description = "Name of the mart layer storage bucket"
  value       = google_storage_bucket.nlcli_ml_training_mart.name
}

output "mart_bucket_url" {
  description = "GCS URL of the mart layer bucket"
  value       = google_storage_bucket.nlcli_ml_training_mart.url
}

output "mart_bucket_self_link" {
  description = "Self link of the mart bucket for IAM bindings"
  value       = google_storage_bucket.nlcli_ml_training_mart.self_link
}
