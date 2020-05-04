variable "common_name" {
  description = "Common name of the certificate."
  type        = string
}

variable "allowed_uses" {
  description = "List of keywords each describing a use that is permitted for the issued certificate."
  type        = list(string)
}

variable "validity_period_hours" {
  description = "The number of hours after initial issuing that the certificate will become invalid."
  default     = 8760
  type        = number
}

variable "ca_key_algorithm" {
  description = "The name of the algorithm for the key provided in ca_private_key_pem."
  type        = string
}

variable "ca_private_key_pem" {
  description = "PEM-encoded private key data for the CA."
  type        = string
}

variable "ca_cert_pem" {
  description = "PEM-encoded certificate data for the CA."
  type        = string
}

