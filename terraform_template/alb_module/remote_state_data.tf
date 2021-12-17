data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "a4-terraform-state"
    key    = "network/terraform.tfstate"
    region = "ap-northeast-2"
    profile = "bespin-aws4"
  }
}

data "terraform_remote_state" "sg" {
  backend = "s3"

  config = {
    bucket = "a4-terraform-state"
    key    = "sg/terraform.tfstate"
    region = "ap-northeast-2"
    profile = "bespin-aws4"
  }
}
