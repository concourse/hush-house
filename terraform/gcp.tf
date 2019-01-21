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

provider "google-beta" {
  credentials = "gcp.json"
  project     = "${var.project}"
  region      = "${var.region}"
}

