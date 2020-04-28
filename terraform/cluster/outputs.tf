output "vpc_uri" {
  value = "${module.vpc.uri}"
}

output "host" {
  value = "https://${google_container_cluster.main.endpoint}"
}

output "username" {
  value = google_container_cluster.master_auth[0].username
}

output "password" {
  sensitive = true
  value = google_container_cluster.master_auth[0].password
}

output "cluster_ca_certificate" {
  value = base64decode(google_container_cluster.master_auth[0].cluster_ca_certificate)
}