variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default      = "mw-udacity-webserver"
}

variable "location" {
  default = "East US"
}

variable "username" {
  description = "Default username for admin"
  default = "adminuser"
}

variable "password" {
  description = "Default password for admin"
  default = ""
}

variable "vm_count" {
  description = "Default vm machines"
  default = 2
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(string)
  default = {
    name = "mw-udacity-vmserver-project"
    }
  }

variable "application_port" {
  description = "port to expose the load balancer"
  default = 80
}
