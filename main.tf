provider "aws" {
  profile = var.profile
  region  = var.aws_region
}

# Deploy Networking Resources
module "networking" {
  source         = "./networking"
  vpc_cidr       = var.vpc_cidr
  public_cidr    = var.public_cidr
  private_cidr_1 = var.private_cidr_1
  private_cidr_2 = var.private_cidr_2
  accessip       = var.accessip
}