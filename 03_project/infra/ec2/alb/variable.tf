variable "target_port" {
  type        = number
  default     = 8080
  description = "The port will use for HTTP requests"
}

variable "http_port" {
  type        = number
  default     = 80
  description = "The port will use for HTTP requests"
}

# variable "ssh_port" {
#   type        = number
#   description = "The port will use for SSH requests"
#   default     = 22
# }