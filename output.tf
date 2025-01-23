output "ec2_ip_publique" {
  description = "IP publique de l'instance EC2"
  value       = aws_instance.juice-shop.public_dns
}