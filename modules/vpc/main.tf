
# VPC
resource "aws_vpc" "this" {
  for_each = var.vpcs

  cidr_block           = each.value.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = each.value.name
  }
}


# Public Subnet
resource "aws_subnet" "public" {
  for_each = var.vpcs

  vpc_id                  = aws_vpc.this[each.key].id
  cidr_block              = each.value.public_subnet_cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = "${each.value.name}-public"
  }
}


# Private Subnet
resource "aws_subnet" "private" {
  for_each = var.vpcs

  vpc_id            = aws_vpc.this[each.key].id
  cidr_block        = each.value.private_subnet_cidr
  availability_zone = each.value.az

  tags = {
    Name = "${each.value.name}-private"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  for_each = var.vpcs

  vpc_id = aws_vpc.this[each.key].id

  tags = {
    Name = "${each.value.name}-igw"
  }
}


# Elastic IP for NAT
resource "aws_eip" "nat" {
  for_each = var.vpcs
  domain   = "vpc"

  tags = {
    Name = "${each.value.name}-nat-eip"
  }
}


# NAT Gateway
resource "aws_nat_gateway" "nat" {
  for_each = var.vpcs

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "${each.value.name}-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}


# Public Route Table
resource "aws_route_table" "public" {
  for_each = var.vpcs

  vpc_id = aws_vpc.this[each.key].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[each.key].id
  }

  tags = {
    Name = "${each.value.name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = var.vpcs

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}


# Private Route Table
resource "aws_route_table" "private" {
  for_each = var.vpcs

  vpc_id = aws_vpc.this[each.key].id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[each.key].id
  }

  tags = {
    Name = "${each.value.name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = var.vpcs

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
