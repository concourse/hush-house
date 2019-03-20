output "hush-house-database-ip" {
  sensitive = true
  value     = "${module.database.ip}"
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
