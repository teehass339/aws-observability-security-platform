resource "aws_vpc" "app-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "app-igw" {
  vpc_id = aws_vpc.app-vpc.id
  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_subnet" "pub-subnet" {
  count             = length(var.public_cidr_block)
  vpc_id            = aws_vpc.app-vpc.id
  cidr_block        = var.public_cidr_block[count.index]
  availability_zone = var.avail_zone[count.index]
  tags = {
    Name = "${var.env}-public-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "pub-route-table" {
  vpc_id = aws_vpc.app-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app-igw.id
  }

  tags = {
    Name = "${var.env}-pub-rt"
  }
}

resource "aws_route_table_association" "pub-rta" {
  count          = length(var.public_cidr_block)
  subnet_id      = aws_subnet.pub-subnet[count.index].id
  route_table_id = aws_route_table.pub-route-table.id
}

resource "aws_eip" "nat-eip" {
  count  = length(var.public_cidr_block)
  domain = "vpc"

  tags = {
    Name = "${var.env}-nat-eip-${count.index + 1}"
  }

}

resource "aws_nat_gateway" "app-ngw" {
  count         = length(var.public_cidr_block)
  allocation_id = aws_eip.nat-eip[count.index].id
  subnet_id     = aws_subnet.pub-subnet[count.index].id

  tags = {
    Name = "${var.env}-ngw-${count.index + 1}"
  }
  depends_on = [aws_internet_gateway.app-igw]
}

resource "aws_subnet" "app-subnet" {
  count             = length(var.private_cidr_block)
  vpc_id            = aws_vpc.app-vpc.id
  cidr_block        = var.private_cidr_block[count.index]
  availability_zone = var.avail_zone[count.index]
  tags = {
    Name = "${var.env}-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "app-route-table" {
  vpc_id = aws_vpc.app-vpc.id
  count  = length(var.private_cidr_block)
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(
      [for ngw in aws_nat_gateway.app-ngw : ngw.id if ngw.subnet_id == aws_subnet.pub-subnet[count.index].id],
      0
    )
  }

  tags = {
    Name = "${var.env}-app-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "app-rta" {
  count          = length(var.private_cidr_block)
  subnet_id      = aws_subnet.app-subnet[count.index].id
  route_table_id = aws_route_table.app-route-table[count.index].id
}


