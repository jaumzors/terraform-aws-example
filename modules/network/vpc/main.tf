data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "random_shuffle" "pvt_az" {
  count        = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  input        = data.aws_availability_zones.available.names
  result_count = 1
}

resource "random_shuffle" "pub_az" {
  count        = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  input        = data.aws_availability_zones.available.names
  result_count = 1
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  vpc_id            = aws_vpc.default.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = random_shuffle.pvt_az[count.index].result[0]

  tags = {
    Name = "private_subnet_${count.index}"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0
  vpc_id                  = aws_vpc.default.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = random_shuffle.pub_az[count.index].result[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_${count.index}"
  }
}

resource "aws_internet_gateway" "default_igw" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "default_igw"
  }
}

resource "aws_route_table" "private_vpc_public_igw_route" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "private_vpc_public_igw_route"
  }
}

resource "aws_route" "private_vpc_to_igw" {
  route_table_id         = aws_route_table.private_vpc_public_igw_route.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default_igw.id
}

resource "aws_route_table_association" "public-subnet-route-association" {
  count          = length(aws_subnet.public_subnets) > 0 ? length(aws_subnet.public_subnets) : 0
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.private_vpc_public_igw_route.id
}

resource "aws_eip" "default" {}

resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.default.id
  subnet_id     = aws_subnet.public_subnets[var.nat_gateway_pub_subnet_index].id

  tags = {
    Env = var.env
  }

  depends_on = [
    aws_eip.default
  ]
}

resource "aws_route_table" "public_vpc_nat_gw_route_table" {
  vpc_id = aws_vpc.default.id

  tags = {
    Name = "public_vpc_nat_gw_route_table"
  }
}

resource "aws_route" "private_vpc_to_nat_gw" {
  route_table_id         = aws_route_table.public_vpc_nat_gw_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.default.id
}

resource "aws_route_table_association" "private-subnet-nat-gw-route-association" {
  subnet_id      = aws_subnet.private_subnets[var.nat_gateway_pvt_subnet_index].id
  route_table_id = aws_route_table.public_vpc_nat_gw_route_table.id
}