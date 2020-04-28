resource "google_compute_network" "main" {
  name = var.name

  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "main" {
  name = "${var.name}-sn-1"

  ip_cidr_range = var.vms_cidr
  network       = google_compute_network.main.name
  region        = var.region

  secondary_ip_range {
    range_name    = var.pods_range_name
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = var.services_range_name
    ip_cidr_range = var.services_cidr
  }
}

resource "google_compute_firewall" "internal_ingress" {
  name = "${var.name}-internal"

  network   = google_compute_network.main.name
  direction = "INGRESS"

  source_ranges = [
    var.vms_cidr,
    var.pods_cidr,
    var.services_cidr,
  ]

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }
}

resource "google_compute_firewall" "external_ingress" {
  name      = "${var.name}-external"
  network   = google_compute_network.main.name
  direction = "INGRESS"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}
