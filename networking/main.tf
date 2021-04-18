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


