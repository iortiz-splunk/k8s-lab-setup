output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the created public subnet."
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "The ID of the created security group."
  value       = aws_security_group.ec2_sg.id
}

output "ec2_public_ips" {
  description = "List of public IP addresses of the EC2 instances."
  value       = aws_instance.web_server.*.public_ip
}

output "ec2_public_dns" {
  description = "List of public DNS names of the EC2 instances."
  value       = aws_instance.web_server.*.public_dns
}