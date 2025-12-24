# Firebase and Firestore Configuration

# DEV PROJECT
# Enable Firebase Management API - Dev
resource "google_project_service" "firebase_dev" {
  project = var.project_id_dev
  service = "firebase.googleapis.com"

  disable_on_destroy = false
}

# Enable Firestore API - Dev
resource "google_project_service" "firestore_dev" {
  project = var.project_id_dev
  service = "firestore.googleapis.com"

  disable_on_destroy = false
}

# Enable Firebase App Check API - Dev
resource "google_project_service" "firebaseappcheck_dev" {
  project = var.project_id_dev
  service = "firebaseappcheck.googleapis.com"

  disable_on_destroy = false
}

# Enable Identity Toolkit API - Dev
resource "google_project_service" "identitytoolkit_dev" {
  project = var.project_id_dev
  service = "identitytoolkit.googleapis.com"

  disable_on_destroy = false
}

# Initialize Firebase project - Dev
resource "google_firebase_project" "dev" {
  provider = google-beta
  project  = var.project_id_dev

  depends_on = [
    google_project_service.firebase_dev,
    google_project_service.firebaseappcheck_dev,
    google_project_service.identitytoolkit_dev,
  ]
}

# Create default Firestore database - Dev
resource "google_firestore_database" "dev" {
  provider    = google-beta
  project     = var.project_id_dev
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  depends_on = [
    google_firebase_project.dev,
    google_project_service.firestore_dev,
  ]
}

# PROD PROJECT
# Enable Firebase Management API - Prod
resource "google_project_service" "firebase_prod" {
  project = var.project_id_prod
  service = "firebase.googleapis.com"

  disable_on_destroy = false
}

# Enable Firestore API - Prod
resource "google_project_service" "firestore_prod" {
  project = var.project_id_prod
  service = "firestore.googleapis.com"

  disable_on_destroy = false
}

# Enable Firebase App Check API - Prod
resource "google_project_service" "firebaseappcheck_prod" {
  project = var.project_id_prod
  service = "firebaseappcheck.googleapis.com"

  disable_on_destroy = false
}

# Enable Identity Toolkit API - Prod
resource "google_project_service" "identitytoolkit_prod" {
  project = var.project_id_prod
  service = "identitytoolkit.googleapis.com"

  disable_on_destroy = false
}

# Initialize Firebase project - Prod
resource "google_firebase_project" "prod" {
  provider = google-beta
  project  = var.project_id_prod

  depends_on = [
    google_project_service.firebase_prod,
    google_project_service.firebaseappcheck_prod,
    google_project_service.identitytoolkit_prod,
  ]
}

# Create default Firestore database - Prod
resource "google_firestore_database" "prod" {
  provider    = google-beta
  project     = var.project_id_prod
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  depends_on = [
    google_firebase_project.prod,
    google_project_service.firestore_prod,
  ]
}
