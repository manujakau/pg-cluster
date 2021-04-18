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