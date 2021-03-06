data "terraform_remote_state" "iam" {
  backend = "s3"

  config = {
    bucket = "aws4-terraform-state"
    key    = "iam/terraform.tfstate"
    region = "ap-northeast-2"
    profile = "bespin-aws4"
  }
}
