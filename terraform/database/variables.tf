variable "name" {
  default     = ""
  description = "The name of the CloudSQL instance to create (ps.: a random ID is appended to this name)"
}

variable "memory_mb" {
  default     = ""
  description = "Number of MBs to assign to the CloudSQL instance."
}

variable "cpus" {
  default     = ""
  description = "Number of CPUs to assign to the CloudSQL instance."
}

variable "zone" {
  default     = ""
  description = "The zone where this instance is supposed to be created at (e.g., us-central1-a)"
}

variable "region" {
  default     = ""
  description = "The region where the instance is supposed to be created at (e.g., us-central1)"
}

variable "disk_size_gb" {
  default     = ""
  description = "The disk size in GB's (e.g. 10)"
}
