data "google_client_config" "current" {}

provider "google" {
  credentials = var.credentials
  project     = var.project
  region      = var.region
}

# `google-beta` provides us access to GCP's beta APIs.
# This is particularly needed for GKE-related operations.
#
provider "google-beta" {
  credentials = var.credentials
  project     = var.project
  region      = var.region
}
