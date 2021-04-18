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
  count         = 1
  instance_type = var.instance_type_1
  ami           = data.aws_ami.server_ami_1.id

  tags = {
    Name = "bastion_host"
  }

  key_name               = var.key_name
  vpc_security_group_ids = [var.ssh_security_group]
  subnet_id              = var.public_subnet_a
  user_data              = data.template_cloudinit_config.cloudinit-bastion.rendered
}