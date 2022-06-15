# Reserved IP address for the `web` instances.
#
# This is needed so that we can have a static IP that `hush-house.pivotal.io`
# can point.
#
resource "google_compute_address" "hush-house" {
  name = "hush-house"
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
      machine-type = "e2-highcpu-8"
      max          = 6
      min          = 1
      preemptible  = false
      version      = "1.18.20-gke.901"
    },

    "workers-3" = {
      auto-upgrade = false
      disk-size    = "50"
      disk-type    = "pd-ssd"
      image        = "UBUNTU"
      local-ssds   = 0
      machine-type = "e2-standard-8"
      max          = 25
      min          = 1
      preemptible  = false
      version      = "1.18.20-gke.901"
    },
  }
}

# Creates the CloudSQL Postgres database to be used by the `hush-house`
# Concourse deployment.
#
module "database" {
  source = "./database"

  name            = "hush-house"
  cpus            = "6"
  memory_mb       = "10240"
  region          = "${var.region}"
  zone            = "${var.zone}"
  max_connections = "300"
}

# gkms key for vault unseal
# Concourse deployment.
#
resource "google_kms_key_ring" "keyring" {
  name     = "vault-helm-unseal-kr"
  location = "global"
}

# crypto key for vault unseal
# Concourse deployment.
#
resource "google_kms_crypto_key" "vault-helm-unseal-key" {
  name            = "vault-helm-unseal-key"
  key_ring        = google_kms_key_ring.keyring.self_link

  lifecycle {
    prevent_destroy = true
  }
}

# gkms key for vault-nci unseal
# Concourse deployment.
#
resource "google_kms_key_ring" "keyring-nci" {
  name     = "vault-helm-unseal-kr-nci"
  location = "global"
}

# crypto key for vault-nci unseal
# Concourse deployment.
#
resource "google_kms_crypto_key" "vault-helm-unseal-key-nci" {
  name            = "vault-helm-unseal-key-nci"
  key_ring        = google_kms_key_ring.keyring-nci.self_link

  lifecycle {
    prevent_destroy = true
  }
}

# Creates the CloudSQL Postgres database to be used by the `vault`
# Concourse deployment.
#
 module "vault-database" {
  source = "./database"

  name            = "vault"
  cpus            = "4"
  disk_size_gb    = "10"
  memory_mb       = "5120"
  region          = "${var.region}"
  zone            = "${var.zone}"
  max_connections = "100"
}
