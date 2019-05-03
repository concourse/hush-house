terraform {
  backend "gcs" {
    credentials = "gcp.json"
    bucket      = "concourse-hush-house"
    prefix      = "terraform-k8s/state"
  }
}

provider "google" {
  credentials = "gcp.json"
  project     = "${var.project}"
  region      = "${var.region}"
}

# `google-beta` provides us access to GCP's beta APIs.
# This is particularly needed for GKE-related operations.
#
provider "google-beta" {
  credentials = "gcp.json"
  project     = "${var.project}"
  region      = "${var.region}"
}
