output "public_subnet_1_id" {
  description = "Public subnet 1 ID"
  value       = aws_subnet.publicsubnet1.id
}

output "public_subnet_2_id" {
  description = "Public subnet 2 ID"
  value       = aws_subnet.publicsubnet2.id
}

output "private_subnet_1_id" {
  description = "Private subnet 1 ID"
  value       = aws_subnet.privatesubnet1.id
}

output "private_subnet_2_id" {
  description = "Private subnet 2 ID"
  value       = aws_subnet.privatesubnet2.id
}
