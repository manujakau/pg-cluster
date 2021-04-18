#VPC
data "aws_availability_zones" "available" {}


resource "aws_vpc" "pg_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "pg_vpc"
  }
}


#internet gateway
resource "aws_internet_gateway" "pg_internet_gateway" {
  vpc_id = aws_vpc.pg_vpc.id

  tags = {
    Name = "pg_igw"
  }
}


# subnets
resource "aws_subnet" "pg_public_subnet" {
  vpc_id                  = aws_vpc.pg_vpc.id
  cidr_block              = var.subnet_cidrs["public1"]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "pg_public_a"
    Tier = "Public"
  }
}

resource "aws_subnet" "pg_private_subnet_a" {
  vpc_id            = aws_vpc.pg_vpc.id
  cidr_block        = var.subnet_cidrs["private1"]
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "pg_private_a"
    Tier = "Private"
  }
}

resource "aws_subnet" "pg_private_subnet_b" {
  vpc_id            = aws_vpc.pg_vpc.id
  cidr_block        = var.subnet_cidrs["private2"]
  availability_zone = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "pg_private_b"
    Tier = "Private"
  }
}


#public route
resource "aws_route_table" "pg_public_rt" {
  vpc_id = aws_vpc.pg_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pg_internet_gateway.id
  }

  tags = {
    Name = "pg_public_rt"
  }
}

# public subnet associations
resource "aws_route_table_association" "pg_public_association" {
  subnet_id      = aws_subnet.pg_public_subnet.id
  route_table_id = aws_route_table.pg_public_rt.id
}



#Elastic Ip
resource "aws_eip" "pg_eip" {
  vpc = true
  tags = {
    Name = "pg_eip"
  }
}


#Nat Gateway
resource "aws_nat_gateway" "pg_nat_gw" {
  allocation_id = aws_eip.pg_eip.id
  subnet_id     = aws_subnet.pg_public_subnet.id

  tags = {
    Name = "pg_nat_gw"
  }
}


#private route s
resource "aws_route_table" "pg_private_rt" {
  vpc_id = aws_vpc.pg_vpc.id

  route {
    cidr_block = var.accessip
    gateway_id = aws_nat_gateway.pg_nat_gw.id
  }

  tags = {
    Name = "pg_private_rt"
  }
}

# private subnet associations a
resource "aws_route_table_association" "pg_private_association_a" {
  subnet_id      = aws_subnet.pg_private_subnet_a.id
  route_table_id = aws_route_table.pg_private_rt.id
}

# private subnet associations b
resource "aws_route_table_association" "pg_private_association_b" {
  subnet_id      = aws_subnet.pg_private_subnet_b.id
  route_table_id = aws_route_table.pg_private_rt.id
}


#security groups
resource "aws_security_group" "pg_bastion_sg" {
  name        = "pg_bastion_sg"
  description = "Used for access to the bastion instances"
  vpc_id      = aws_vpc.pg_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.accessip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pg_bastion_sg"
  }
}

resource "aws_security_group" "pg_app_sg" {
  name        = "pg_app_sg"
  description = "Used for access to the app instances"
  vpc_id      = aws_vpc.pg_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.pg_bastion_sg.id]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.accessip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pg_app_sg"
  }
}

resource "aws_security_group" "pg_db_sg" {
  name        = "pg_db_sg"
  description = "Used for access to the db instances"
  vpc_id      = aws_vpc.pg_vpc.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.pg_bastion_sg.id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.pg_app_sg.id]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      var.subnet_cidrs["private1"],
      var.subnet_cidrs["private2"]
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pg_db_sg"
  }
}