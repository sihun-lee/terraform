resource "aws_s3_bucket" "terraform-state" {
  bucket = "aws20-terraform-state-1"

  # # 실수로 버킷을 삭제하는 것 방지
  #     lifecycle {
  #       prevent_destroy = true
  #     }
  lifecycle {
    prevent_destroy = false
  }
  force_destroy = true

  tags = {
    Name = "aws20-terraform-state-1"
  }
}

#locking 기능을 위한 dynamo db 생성
resource "aws_dynamodb_table" "terraform-locks" {
  name         = "aws20-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}