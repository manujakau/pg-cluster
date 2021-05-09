provider "aws" {
  profile = var.profile
  region  = var.aws_region
}

# Deploy Networking Resources
module "networking" {
  source       = "./networking"
  vpc_cidr     = var.vpc_cidr
  subnet_cidrs = var.subnet_cidrs
  accessip     = var.accessip
}

# Deploy Compute Resources
module "compute" {
  source             = "./compute"
  region             = var.aws_region
  key_name           = var.key_name
  instance_type_1    = var.instances_type01
  instance_type_2    = var.instances_type02
  remote_user        = var.remote_user
  remote_password    = var.remote_password
  psql_version       = var.psql_version
  public_subnet_a    = module.networking.public_subnet_a
  private_subnet_a   = module.networking.private_subnet_a
  private_subnet_b   = module.networking.private_subnet_b
  ssh_security_group = module.networking.bastion_security_group
  app_security_group = module.networking.application_security_group
  dbm_security_group = module.networking.db_master_security_group
  dbs_security_group = module.networking.db_slave_security_group
  nat_depend         = module.networking.nat_depend
  rt_depend          = module.networking.rt_depend
}