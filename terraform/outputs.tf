output "instance_ip" {
  value = "${google_compute_address.web.address}"
}
