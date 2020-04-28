output "name" {
  value = "${google_compute_network.main.name}"
}

output "subnet_name" {
  value = "${google_compute_subnetwork.main.name}"
}

output "pods_range_name" {
  value = "${var.pods_range_name}"
}

output "services_range_name" {
  value = "${var.services_range_name}"
}

output "uri" {
  value = "${google_compute_network.main.self_link}"
}
