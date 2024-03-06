output "ssh" {
    value = aws_security_group.ssh.id
}

output "http" {
    value = aws_security_group.http.id
}

output "https" {
    value = aws_security_group.https.id
}

output "target_http" {
    value = aws_security_group.target_http.id
}