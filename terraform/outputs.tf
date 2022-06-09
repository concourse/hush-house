# hush-house database outputs
output "hush-house-database-ip" {
  value = "${module.database.ip}"
}

output "hush-house-database-ca-cert" {
  sensitive = true
  value     = "${module.database.ca-cert}"
}

output "hush-house-database-password" {
  sensitive = true
  value     = "${module.database.password}"
}

output "hush-house-database-cert" {
  sensitive = true
  value     = "${module.database.cert}"
}

output "hush-house-database-private-key" {
  sensitive = true
  value     = "${module.database.private-key}"
}

# vault database outputs
output "vault-database-ip" {
  value = "${module.vault-database.ip}"
}

output "vault-database-ca-cert" {
  sensitive = true
  value     = "${module.vault-database.ca-cert}"
}

output "vault-database-password" {
  sensitive = true
  value     = "${module.vault-database.password}"
}

output "vault-database-cert" {
  sensitive = true
  value     = "${module.vault-database.cert}"
}

output "vault-database-private-key" {
  sensitive = true
  value     = "${module.vault-database.private-key}"
}

output "hush-house-address" {
  value = "${google_compute_address.hush-house.address}"
}
