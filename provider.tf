terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.32.0"
    }
  }

}

provider "aws" {

  region     = "us-east-1"
  access_key = ""
  secret_key = ""
}

