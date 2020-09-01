variable "location" {
  type = string
  default = "westeurope"
}

variable "prefix" {
  type = string
  default = "wagtail"
}

variable "ssh-source-address" {
  type = string
  default = "*"
}
