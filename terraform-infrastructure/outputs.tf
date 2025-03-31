#output the public IP addresses of the EC2 instances
output "instance1_public_ip" {
  description = "Public IP address of the first EC2 instance"
  value       = aws_instance.app_server_1.public_ip
}

output "instance2_public_ip" {
  description = "Public IP address of the second EC2 instance"
  value       = aws_instance.app_server_2.public_ip
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.rds_instance.endpoint
}