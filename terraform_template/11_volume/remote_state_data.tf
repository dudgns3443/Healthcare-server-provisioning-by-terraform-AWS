# 필요한 모듈 사용하면 됨# vpc, subnet, ig, ng, rout-table
data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "aws4-terraform-state"
    key    = "network/terraform.tfstate"
    region = "ap-northeast-2"
    profile = "bespin-aws4"
  }
}
