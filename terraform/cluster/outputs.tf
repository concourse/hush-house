output "endpoint" {
  value = google_container_cluster.main.endpoint
}

output "client_certificate" {
  value = google_container_cluster.main.master_auth[0].client_certificate
}

output "client_key" {
  value = google_container_cluster.main.master_auth[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value = google_container_cluster.main.master_auth[0].cluster_ca_certificate
}

output "node_pools" {
  value = google_container_node_pool.main
}