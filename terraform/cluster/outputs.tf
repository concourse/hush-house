output "vpc_uri" {
  value = "${module.vpc.uri}"
}

output "endpoint" {
  value = google_container_cluster.main.endpoint
}

output "cluster_ca_certificate" {
  value = google_container_cluster.master_auth[0].cluster_ca_certificate
}