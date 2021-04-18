profile = "default"

aws_region = "eu-north-1"

vpc_cidr = "10.0.0.0/20"

subnet_cidrs = {
  public1  = "10.0.1.0/28"
  private1 = "10.0.2.0/28"
  private2 = "10.0.3.0/28"
}

accessip = "0.0.0.0/0"

key_name = "WP"

instances_type01 = "t3.micro"

instances_type02 = "t3.small"