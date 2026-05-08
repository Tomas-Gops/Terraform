variable "external_port" {
  description = "Port exposed on the host machine"
  type        = number
  default     = 8080
}

variable "backend_count" {
  description = "Number of backend containers"
  type        = number
  default     = 2
}