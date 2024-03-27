
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    name = var.env_code
  }
}


data "aws_availability_zones" "available-names" {
  state = "available"
}

resource "aws_subnet" "public" {
  count = length(var.public_cidr)

  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_cidr[count.index]

  map_public_ip_on_launch = true

  availability_zone = data.aws_availability_zones.available-names.names[count.index]

  tags = {
    name = "${var.env_code}-public${count.index}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    name = var.env_code
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_cidr)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}


