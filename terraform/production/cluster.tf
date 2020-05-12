# Instantiates the GKE Kubernetes cluster.
#
module "cluster" {
  source = "../cluster"

  name    = "production"
  project = var.project
  region  = var.region
  zone    = var.zone

  release_channel = "STABLE"

  node_pools = {
    "generic-1" = {
      auto_upgrade       = true
      disk_size          = "50"
      disk_type          = "pd-ssd"
      image              = "COS"
      local_ssds         = 0
      machine_type       = "n1-standard-8"
      max                = 5
      min                = 1
      preemptible        = false
      service_account    = null
      extra_oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform",
      ]
    },
  }
}