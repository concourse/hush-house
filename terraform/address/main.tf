data "google_dns_managed_zone" "main" {
  name = "${var.dns-zone}"
}

resource "google_compute_address" "main" {
  name = "${var.subdomain}"
}

resource "google_dns_record_set" "main" {
  name = "${var.subdomain}.${data.google_dns_managed_zone.main.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = "${data.google_dns_managed_zone.main.name}"

  rrdatas = [
    "${google_compute_address.main.address}",
  ]
}
