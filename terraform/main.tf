# Reserved IP address for the `web` instances.
#
# This is needed so that we can have a static IP that `hush-house.pivotal.io`
# can point.
#
resource "google_compute_address" "hush-house" {
  name = "hush-house"
}

# Reserves an address for `nci.concourse-ci.org` and ties it
# to the given domain.
#
module "concourse-nci-address" {
  source = "./address"

  dns-zone  = "${var.dns-zone}"
  subdomain = "nci"
}

# Reserves an address for `metrics-hush-house.concourse-ci.org` and ties it
# to the given domain.
#
module "metrics-address" {
  source = "./address"

  dns-zone  = "${var.dns-zone}"
  subdomain = "metrics-hush-house"
}

# Instantiates the GKE Kubernetes cluster.
#
module "cluster" {
  source = "./cluster"

  name   = "hush-house"
  zone   = "${var.zone}"
  region = "${var.region}"

  node-pools = {

    "generic-1" = {
      auto-upgrade = false
      disk-size    = "50"
      disk-type    = "pd-ssd"
      image        = "COS"
      local-ssds   = 0
      machine-type = "n1-standard-4"
      max          = 5
      min          = 1
      node_count   = 4
      preemptible  = false
      version      = "1.12.5-gke.5"
    },

    "workers-3" = {
      auto-upgrade = false
      disk-size    = "50"
      disk-type    = "pd-ssd"
      image        = "UBUNTU"
      local-ssds   = 0
      machine-type = "custom-8-16384"
      max          = 20
      min          = 1
      node_count   = 15
      preemptible  = false
      version      = "1.14.7-gke.14 "
    },

     "ci-workers" = {
      auto-upgrade = false
      disk-size    = "50"
      disk-type    = "pd-ssd"
      image        = "COS"
      local-ssds   = 0
      machine-type = "custom-8-16384"
      max          = 10
      min          = 1
      node_count   = 8
      preemptible  = false
      version      = "1.14.7-gke.14 "
    },

     "ci-workers-pr" = {
      auto-upgrade = false
      disk-size    = "50"
      disk-type    = "pd-ssd"
      image        = "COS"
      local-ssds   = 0
      machine-type = "custom-8-16384"
      max          = 10
      min          = 1
      node_count   = 3
      preemptible  = false
      version      = "1.14.7-gke.14 "
    },
  }
}

# Creates the CloudSQL Postgres database to be used by the `hush-house`
# Concourse deployment.
#
module "database" {
  source = "./database"

  name            = "hush-house"
  cpus            = "4"
  disk_size_gb    = "25"
  memory_mb       = "5120"
  region          = "${var.region}"
  zone            = "${var.zone}"
  max_connections = "300"
}

# Creates the CloudSQL Postgres database to be used by the `ci`
# Concourse deployment.
#
module "ci-database" {
  source = "./database"

  name            = "ci"
  cpus            = "4"
  disk_size_gb    = "20"
  memory_mb       = "5120"
  region          = "${var.region}"
  zone            = "${var.zone}"
  max_connections = "100"
}
