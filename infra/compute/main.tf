#ami
data "aws_ami" "server_ami_1" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*-x86_64-gp2"]
  }
}

data "aws_ami" "server_ami_2" {
  most_recent = true
  owners      = ["099720109477"] #Canonical

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}


#ec2
resource "aws_instance" "bastion_host" {
  instance_type        = var.instance_type_1
  ami                  = data.aws_ami.server_ami_1.id
  iam_instance_profile = aws_iam_instance_profile.pg_cluster_profile.name

  tags = {
    Name = "bastion_host"
  }

  key_name               = var.key_name
  vpc_security_group_ids = [var.ssh_security_group]
  subnet_id              = var.public_subnet_a
  user_data              = data.template_cloudinit_config.cloudinit-bastion.rendered
}

resource "aws_instance" "application_host" {
  instance_type = var.instance_type_2
  ami           = data.aws_ami.server_ami_2.id

  tags = {
    Name = "application_host"
  }

  key_name               = var.key_name
  vpc_security_group_ids = [var.app_security_group]
  subnet_id              = var.public_subnet_a
  user_data              = data.template_cloudinit_config.cloudinit-application.rendered
}

resource "aws_instance" "db_master_host" {
  instance_type = var.instance_type_2
  ami           = data.aws_ami.server_ami_2.id

  tags = {
    Name = "db_master_host"
  }

  key_name               = var.key_name
  vpc_security_group_ids = [var.dbm_security_group]
  subnet_id              = var.private_subnet_a
  user_data              = data.template_cloudinit_config.cloudinit-pgmaster.rendered
}

resource "aws_instance" "db_slave_host" {
  instance_type = var.instance_type_2
  ami           = data.aws_ami.server_ami_2.id

  tags = {
    Name = "db_slave_host"
  }

  key_name               = var.key_name
  vpc_security_group_ids = [var.dbs_security_group]
  subnet_id              = var.private_subnet_b
  user_data              = data.template_cloudinit_config.cloudinit-pgslave.rendered
}