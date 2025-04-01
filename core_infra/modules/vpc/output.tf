output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet."
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet."
  value       = aws_subnet.private.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = aws_internet_gateway.this.id
}




output "public_route_table" {
  description = "The ID of Public Subnet Route Table."
  value       = aws_route_table.public_route_table.id
}


output "private_route_table" {
  description = "The ID of Private Subnet Route Table."
  value       = aws_route_table.private_route_table.id
}
