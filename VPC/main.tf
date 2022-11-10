resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ngnix_main_vpc"
  }
}

resource "aws_subnet" "public_subnetA" {
  vpc_id      = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block = "10.0.1.0/24"
  availability_zone  = "us-west-2b"
    tags = {
    Name = "public_subnetA"
  }
}

resource "aws_subnet" "public_subnetB" {
  vpc_id      = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block = "10.0.2.0/24"
  availability_zone  = "us-west-2c"
    tags = {
    Name = "public_subnetB"
  }
}

resource "aws_route_table" "ngnix_public_rt" {
   vpc_id      = aws_vpc.main.id
    tags = {
    Name = "ngnix_public_rt"
  }
}

resource "aws_internet_gateway" "ngnix_gw" {
 vpc_id      = aws_vpc.main.id
    tags = {
    Name = "ngnix_gw"
  }
}

resource "aws_route_table_association" "ngnix_public_rta" {
  subnet_id      = aws_subnet.public_subnetA.id
  route_table_id = aws_route_table.ngnix_public_rt.id
}

resource "aws_route_table_association" "ngnix_public_rtb" {
  subnet_id      = aws_subnet.public_subnetB.id
  route_table_id = aws_route_table.ngnix_public_rt.id
}

resource "aws_route" "ngnix_gateway" {
  route_table_id = aws_route_table.ngnix_public_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id     = aws_internet_gateway.ngnix_gw.id
}

resource "aws_network_acl" "ngnix_NACL" {
  vpc_id = aws_vpc.main.id
}

resource "aws_network_acl_rule" "ngrule" {
  network_acl_id = aws_network_acl.ngnix_NACL.id
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "49.206.45.123/32"
  from_port      = 80
  to_port        = 80
}