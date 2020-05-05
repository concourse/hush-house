# Instantiates the GKE Kubernetes cluster.
#
module "cluster" {
  source = "../cluster"

  name   = "production"
  region = var.region
  zone   = var.zone

  release_channel = "STABLE"

  node_pools = {
    "generic-1" = {
      auto_upgrade    = true
      disk_size       = "50"
      disk_type       = "pd-ssd"
      image           = "COS"
      local_ssds      = 0
      machine_type    = "n1-standard-8"
      max             = 5
      min             = 1
      preemptible     = false
      service_account = null
    },
    "vault" = {
      auto_upgrade    = true
      disk_size       = "10"
      disk_type       = "pd-ssd"
      image           = "COS"
      local_ssds      = 0
      machine_type    = "n1-standard-8"
      max             = 1
      min             = 1
      preemptible     = false
      service_account = google_service_account.production_vault.email
    },
  }
}