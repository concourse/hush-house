variable "name" {
  default     = ""
  description = "TODO"
}

variable "memory_mb" {
  default     = ""
  description = "TODO"
}

variable "cpus" {
  default     = ""
  description = "TODO"
}

variable "zone" {
  default     = ""
  description = "TODO"
}

variable "region" {
  default     = ""
  description = "TODO"
}

variable "vpc-uri" {
  type        = "string"
  description = "The URI of the private network resource (resource.self_link)"
}
