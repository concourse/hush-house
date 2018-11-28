terraform {
  backend "gcs" {
    credentials = "gcp.json"
    bucket      = "concourse-hush-house"
    prefix      = "terraform-k8s/state"
  }
}
