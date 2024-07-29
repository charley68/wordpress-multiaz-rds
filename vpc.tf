#vpc
resource "aws_vpc" "this" {
  cidr_block = "10.100.0.0/16"
  tags = {
    Name = "steve-vpc"
  }
}

#public subnets
resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.100.1.0/24"
  availability_zone = var.availability_zone[0]

  tags = {
    Name = "${var.project}-public-1"
    Type = "Public"
  }
}
resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.100.2.0/24"
  availability_zone = var.availability_zone[1]

  tags = {
    Name = "${var.project}-public-2"
    Type = "Public"
  }
}

#private subnets
resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.100.3.0/24"
  availability_zone = var.availability_zone[0]

  tags = {
    Name = "${var.project}-private-1"
    Type = "Private"
  }
}
resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.100.4.0/24"
  availability_zone = var.availability_zone[1]

  tags = {
    Name = "${var.project}-private-2"
    Type = "Private"
  }
}


#internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project}-igw"
  }
}

#elastic ip
resource "aws_eip" "eip" {
  domain = "vpc"
}

#nat gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "${var.project}-nat"
  }
}

#public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project}-public-rt"
  }
}

#private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.project}-private-rt"
  }
}

#route table association
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private.id
}
