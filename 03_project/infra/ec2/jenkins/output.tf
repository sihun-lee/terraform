output "jenkins_private_ip" {
  value = aws_instance.jenkins.private_ip
}

output "jenkins_id" {
  value = aws_instance.jenkins.id
}