terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.27.0"
    }
  }
     cloud {
     organization = "LUIT-3_Tier"

     workspaces {
       name = "New-3-Tier-System-Version-Control-Terrafom"
     }
   }
}

provider "aws" {
  region = "eu-west-2"
  access_key = "********************"
  secret_key = "**********************"
}