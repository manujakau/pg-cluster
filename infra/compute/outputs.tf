output "app_public_ip" {
  value = aws_instance.application_host.public_ip
}