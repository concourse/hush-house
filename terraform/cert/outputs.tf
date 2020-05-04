output "cert_pem" {
  value = tls_locally_signed_cert.cert.cert_pem
}

output "private_key_pem" {
  value = tls_private_key.cert.private_key_pem
}