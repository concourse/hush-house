provider "google" {
  credentials = "gcp.json"
  project     = "cf-concourse-production"
  region      = "us-central1"
}

resource "google_compute_address" "web" {
  name = "k8s-hush-house"
}

data "google_dns_managed_zone" "concourse-ci-org" {
  name = "concourse-ci-org"
}

resource "google_dns_record_set" "web" {
  name = "hush-house.${data.google_dns_managed_zone.concourse-ci-org.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${data.google_dns_managed_zone.concourse-ci-org.name}"

  rrdatas = [
    "${google_compute_address.web.address}",
  ]
}
