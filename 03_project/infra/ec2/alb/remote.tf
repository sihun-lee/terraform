data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    region = "ap-northeast-2"
    bucket = "aws20-terraform-state-1"
    key    = "infra/vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "security_group" {
  backend = "s3"
  config = {
    region = "ap-northeast-2"
    bucket = "aws20-terraform-state-1"
    key    = "infra/ec2/security_group/terraform.tfstate"
  }
}

data "terraform_remote_state" "jenkins_instance" {
  backend = "s3"
  config = {
    region = "ap-northeast-2"
    bucket = "aws20-terraform-state-1"
    key    = "infra/ec2/jenkins/terraform.tfstate"
  }
}