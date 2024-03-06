resource "aws_instance" "jenkins" {
  ami           = "ami-09eb4311cbaecf89d"
  instance_type = "t3.large"
  key_name      = "aws20-key"
  private_ip    = "10.20.64.100"

  subnet_id = data.terraform_remote_state.vpc.outputs.private-subnet-2a-id

  vpc_security_group_ids = [data.terraform_remote_state.security_group.outputs.ssh,
  data.terraform_remote_state.security_group.outputs.http]

  user_data = templatefile("templates/userdata.sh", {})

  # security_groups = [data.terraform_remote_state.security_groups.outputs.ssh_id]

  tags = {
    Name = "aws20-jenkins"
  }
}