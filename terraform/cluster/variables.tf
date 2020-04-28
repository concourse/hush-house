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

variable "node_pools" {
  description = "A list of node pool configurations to create and assign to the cluster."
}

variable "release_channel" {
  default     = "UNSPECIFIED"
  description = "The frequency of automatic updates to the Kubernetes cluster. One of UNSPECIFIED (no updates), RAPID, REGULAR, or STABLE."
}
