terraform {
  backend "s3" {
    bucket         = "aws20-terraform-state-1"
    region         = "ap-northeast-2"
    key            = "global/s3/terraform.tfstate"
    dynamodb_table = "aws20-terraform-locks"
    encrypt        = true
  }
}