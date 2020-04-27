# Instantiates the GKE Kubernetes cluster.
#
module "cluster" {
  source = "../cluster"

  name   = "production"
  project = var.project
  region = var.region
  zone   = var.zone
}
