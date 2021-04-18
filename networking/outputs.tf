output "vpcid" {
  value = aws_vpc.pg_vpc.id
}

output "public_subnet_a" {
  value = aws_subnet.pg_public_subnet_a.id
}

output "private_subnet_a" {
  value = aws_subnet.pg_private_subnet_a.id
}

output "private_subnet_b" {
  value = aws_subnet.pg_private_subnet_b.id
}