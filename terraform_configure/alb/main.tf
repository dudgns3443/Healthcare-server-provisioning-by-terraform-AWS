provider "aws" {
  region = "ap-northeast-2"
  profile = "bespin-aws4"
}

terraform {
  backend "s3" {
    encrypt        = true
    key            = "alb/terraform.tfstate"

    region         = "ap-northeast-2" 
    profile        = "bespin-aws4"
    bucket         = "a4-terraform-state"
  }

  required_version = ">= 0.12.0"
}

module "alb" {
  source = "../../terraform_template/alb_module"
}
