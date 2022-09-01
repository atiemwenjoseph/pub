variable "vpc_cidr" {
  type = string
  default = "10.123.0.0/16"
}

variable "public_sn_count" {
  type = number
  default = 2
}

variable "private_sn_count" {
  type = number
  default = 2
}

variable "access_ip" {
  type = string
  default = "0.0.0.0/0"
}

variable "db_subnet_group" {
  type = bool
  default = true
}

variable "availabilityzone" {
  type = string
  default = "eu-west-2"
}

variable "azs" {
  type = string
  default = "eu-west-2"
}

