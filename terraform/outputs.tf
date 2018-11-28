output "web-address" {
  value = "${google_compute_address.web.address}"
}

output "metrics-address" {
  value = "${google_compute_address.metrics.address}"
}
