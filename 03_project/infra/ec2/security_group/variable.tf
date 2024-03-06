variable "ssh_port" {
  default     = 22
  type        = number
  description = "The port will be used for SSH"
}

variable "http_port" {
  default     = 80
  type        = number
  description = "The port will be used for http"
}

variable "https_port" {
  default     = 443
  type        = number
  description = "The port will be used for http"
}

variable "target_port" {
  default     = 8080
  type        = number
  description = "The port will be used for HTTP 8080 requests"

}