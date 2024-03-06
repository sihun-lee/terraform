variable "web_port" {
  type        = number
  description = "The port will use for HTTP requests"
  default     = 8080
}

variable "ssh_port" {
  type        = number
  description = "The port will use for SSH requests"
  default     = 22
}