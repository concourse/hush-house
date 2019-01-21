output "hush-house-web-ip" {
  sensitive = true
  value = "${module.web-address.ip}"
}

output "hush-house-metrics-ip" {
  sensitive = true
  value = "${module.metrics-address.ip}"
}

output "hush-house-database-ip" {
  sensitive = true
  value = "${module.database.ip}"
}

output "hush-house-database-ca-cert" {
  sensitive = true
  value = "${module.database.ca-cert}"
}

output "hush-house-database-password" {
  sensitive = true
  value = "${module.database.password}"
}
