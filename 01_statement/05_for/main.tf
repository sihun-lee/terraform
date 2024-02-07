provider "local" {
}
variable "names" {
  description = "A list of names"
  #   type        = list(string)
  #   default     = ["neo", "trinity", "morpheus"]
  type = map(string)
  default = {
    neo      = "hero"
    trinity  = "love interest"
    morpheus = "mentor"
  }
}

# output "upper_names" {
#   value = [for name in var.names : upper(name)]
# }

# output "short_upper_names" {
#   value = [for name in var.names : upper(name) if length(name)<5]
# }

# output "bios" {
#   value = [for name, role in var.names : "${name} is the ${role}"]
# }

# A => B : A가 key, B가 value 지정
output "upper_roles" {
  value = { for name, role in var.names : upper(name) => upper(role) }
}