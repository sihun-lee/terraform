data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region = "ap-northeast-2"
    bucket = "aws20-terraform-state-1"
    key    = "infra/vpc/terraform.tfstate"
  }
}