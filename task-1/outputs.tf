output "ec2_public_ip" {
  value = aws_instance.web.public_ip
}

output "apache_url" {
  value = "http://${aws_instance.web.public_ip}"
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}