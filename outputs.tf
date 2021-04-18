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