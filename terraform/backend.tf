terraform {
  backend "gcs" {
    bucket = "nlcli-terraform-state-<ZEST_PROJECT_ID>"
    prefix = "nlcli-wizard/state"
  }
}
