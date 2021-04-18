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

output "db_security_group" {
  value = module.networking.db_security_group
}