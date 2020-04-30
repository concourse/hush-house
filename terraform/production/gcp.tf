provider "google" {
  credentials = var.credentials
  project     = var.project
  region      = var.region
}

# `google-beta` provides us access to GCP's beta APIs.
# This is particularly needed for GKE-related operations.
# It's also used to access the Secret Manager
#
provider "google-beta" {
  credentials = var.credentials
  project     = var.project
  region      = var.region
}

data "google_client_config" "current" {}