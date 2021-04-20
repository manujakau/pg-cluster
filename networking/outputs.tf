output "vpcid" {
  value = aws_vpc.pg_vpc.id
}

output "public_subnet_a" {
  value = aws_subnet.pg_public_subnet.id
}

output "private_subnet_a" {
  value = aws_subnet.pg_private_subnet_a.id
}

output "private_subnet_b" {
  value = aws_subnet.pg_private_subnet_b.id
}

output "bastion_security_group" {
  value = aws_security_group.pg_bastion_sg.id
}

output "application_security_group" {
  value = aws_security_group.pg_app_sg.id
}

output "db_master_security_group" {
  value = aws_security_group.pg_dbm_sg.id
}

output "db_slave_security_group" {
  value = aws_security_group.pg_dbs_sg.id
}

output "nat_depend" {
  value = aws_nat_gateway.pg_nat_gw
}

output "rt_depend" {
  value = aws_route_table.pg_private_rt
}