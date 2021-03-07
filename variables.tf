variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default      = "mw-webserver1"
}

variable "location" {
  default = "East US"
}

variable "admin_username" {
  description = "Default username for admin"
  default = "adminuser"
}

variable "admin_password" {
  description = "Default password for admin"
  default = "MWwebserver2021"
}

variable "vm_count" {
  description = "Default vm machines"
  default = 2
}

variable "tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {
    environment = "MW-Udacity-vm-project"
  }
}

variable "application_port" {
  description = "port to expose the load balancer"
  default = 80
}
