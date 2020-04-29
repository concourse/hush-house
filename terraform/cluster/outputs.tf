output "endpoint" {
  value = google_container_cluster.main.endpoint
}

output "username" {
  value = google_container_cluster.main.master_auth[0].username
}

output "password" {
  value = google_container_cluster.main.master_auth[0].password
  sensitive = true
}

output "cluster_ca_certificate" {
  value = google_container_cluster.main.master_auth[0].cluster_ca_certificate
}

output "node_pools" {
  value = [
    google_container_node_pool.main,
  ]
}