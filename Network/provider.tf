terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.27.0"
    }
  }
}

# provider "aws" {
  
# }


variable "region" {
  type    = string
  default = "eu-west-2"
}