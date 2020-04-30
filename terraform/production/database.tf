# Creates the CloudSQL Postgres database to be used by the `ci`
# Concourse deployment.
#
module "ci_database" {
  source = "../database"

  name            = "ci"
  cpus            = "4"
  disk_size_gb    = "20"
  memory_mb       = "5120"
  region          = "${var.region}"
  zone            = "${var.zone}"
  max_connections = "100"
}