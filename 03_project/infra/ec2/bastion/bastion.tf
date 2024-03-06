resource "aws_instance" "bastion" {
  ami           = "ami-09eb4311cbaecf89d"
  instance_type = "t2.micro"
  key_name      = "aws20-key"

  subnet_id = data.terraform_remote_state.vpc.outputs.public-subnet-2a-id
  associate_public_ip_address = true

  vpc_security_group_ids = [data.terraform_remote_state.security_group.outputs.ssh]

# security_groups = [data.terraform_remote_state.security_groups.outputs.ssh]

  tags = {
    Name = "aws20-bastion"
  }
}