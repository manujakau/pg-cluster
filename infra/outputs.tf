output "vpcid" {
  value = module.networking.vpcid
}

output "public_subnet_a" {
  value = module.networking.public_subnet_a
}

output "private_subnet_a" {
  value = module.networking.private_subnet_a
}

output "private_subnet_b" {
  value = module.networking.private_subnet_b
}

output "bastion_security_group" {
  value = module.networking.bastion_security_group
}

output "application_security_group" {
  value = module.networking.application_security_group
}

output "db_master_security_group" {
  value = module.networking.db_master_security_group
}

output "db_slave_security_group" {
  value = module.networking.db_slave_security_group
}

output "app_public_ip" {
  value = module.compute.app_public_ip
}