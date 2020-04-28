# hush-house database outputs
output "hush_house_database_ip" {
  value = "${module.database.ip}"
}

output "hush_house_database_ca_cert" {
  sensitive = true
  value     = "${module.database.ca_cert}"
}

output "hush_house_database_password" {
  sensitive = true
  value     = "${module.database.password}"
}

output "hush_house_database_cert" {
  sensitive = true
  value     = "${module.database.cert}"
}

output "hush_house_database_private_key" {
  sensitive = true
  value     = "${module.database.private_key}"
}

# ci database outputs
output "ci_database_ip" {
  value = "${module.ci_database.ip}"
}

output "ci_database_ca_cert" {
  sensitive = true
  value     = "${module.ci_database.ca_cert}"
}

output "ci_database_password" {
  sensitive = true
  value     = "${module.ci_database.password}"
}

output "ci_database_cert" {
  sensitive = true
  value     = "${module.ci_database.cert}"
}

output "ci_database_private_key" {
  sensitive = true
  value     = "${module.ci_database.private_key}"
}

# vault database outputs
output "vault_database_ip" {
  value = "${module.vault_database.ip}"
}

output "vault_database_ca_cert" {
  sensitive = true
  value     = "${module.vault_database.ca_cert}"
}

output "vault_database_password" {
  sensitive = true
  value     = "${module.vault_database.password}"
}

output "vault_database_cert" {
  sensitive = true
  value     = "${module.vault_database.cert}"
}

output "vault_database_private_key" {
  sensitive = true
  value     = "${module.vault_database.private_key}"
}

output "hush_house_address" {
  value = "${google_compute_address.hush_house.address}"
}

output "metrics_hush_house_address" {
  value = "${module.metrics_address.address}"
}

output "concourse_ci_address" {
  value = "${module.concourse_ci_address.address}"
}

output "tracing_address" {
  value = "${module.tracing_address.address}"
}
