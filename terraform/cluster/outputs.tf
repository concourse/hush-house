output "vpc_uri" {
  value = "${module.vpc.uri}"
}

output "host" {
  value = "https://${google_container_cluster.main.endpoint}"
}

output "client_certificate" {
  value = google_container_cluster.master_auth[0].client_certificate
}

output "client_key" {
  sensitive = true
  value = google_container_cluster.master_auth[0].client_key
}

output "cluster_ca_certificate" {
  value = google_container_cluster.master_auth[0].cluster_ca_certificate
}