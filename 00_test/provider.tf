provider "aws" {
  region = "ap-northeast-2"
}

data "aws_vpc" "test" {
  default = true
}

data "aws_subnets" "test" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.test.id]
  }
}

data "aws_subnet" "example" {
  for_each = toset(data.aws_subnets.test.ids)
  id       = each.value
}