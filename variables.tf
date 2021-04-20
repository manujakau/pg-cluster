
variable "profile" {}

variable "aws_region" {}

#networking variables

variable "vpc_cidr" {}

variable "subnet_cidrs" {
  type = map(string)
}

variable "accessip" {}

#compute variables

variable "key_name" {}

variable "instances_type01" {}

variable "instances_type02" {}

variable "remote_user" {}

variable "remote_password" {}

variable "psql_version" {}