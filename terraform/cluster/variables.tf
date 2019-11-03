variable "name" {
  default     = ""
  description = "The name of the GKE cluster to be created."
}

variable "zone" {
  default     = ""
  description = "The zone where the cluster should live."
}

variable "region" {
  default     = ""
  description = "The region in which the cluster should be located at."
}

variable "node-pools" {
  description = "A list of node pool configurations to create and assign to the cluster."
}
