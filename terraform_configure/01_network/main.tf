provider "aws" {
  region = "ap-northeast-2"
  profile = "bespin-aws4"
}

terraform {
  backend "s3" {
    encrypt        = true
    key            = "network/terraform.tfstate"

    region         = "ap-northeast-2" 
    profile        = "bespin-aws4"
    bucket         = "aws4-terraform-state"
    dynamodb_table = "a4-terraform-locks"
  }

  required_version = ">= 0.12.0"
}


module "network" {
  source = "git::git@github.com:dudgns3443/AWS4FinalProject.git//network?ref=network-v0.0.1"

  remote_bucket_name = var.remote_bucket_name
  region = var.region
  key = var.key
  name = var.name
  
}

