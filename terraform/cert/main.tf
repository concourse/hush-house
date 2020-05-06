resource "tls_private_key" "cert" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "tls_cert_request" "cert" {
  key_algorithm = tls_private_key.cert.algorithm
  private_key_pem = tls_private_key.cert.private_key_pem

  subject {
    common_name = var.common_name
  }

  dns_names = var.dns_names
}

resource "tls_locally_signed_cert" "cert" {
  cert_request_pem = tls_cert_request.cert.cert_request_pem

  ca_key_algorithm = var.ca_key_algorithm
  ca_private_key_pem = var.ca_private_key_pem
  ca_cert_pem = var.ca_cert_pem

  validity_period_hours = var.validity_period_hours

  allowed_uses = var.allowed_uses
}