#VPC 생성
resource "aws_vpc" "aws20-vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "aws20-vpc"
  }
}


#서브넷 생성
resource "aws_subnet" "aws20-public-subnet-2a" {
  vpc_id            = aws_vpc.aws20-vpc.id
  cidr_block        = var.public_subnet[0]
  availability_zone = var.azs[0]

  tags = {
    Name = "aws20-public-subnet-2a"
  }
}

resource "aws_subnet" "aws20-public-subnet-2c" {
  vpc_id            = aws_vpc.aws20-vpc.id
  cidr_block        = var.public_subnet[1]
  availability_zone = var.azs[1]

  tags = {
    Name = "aws20-public-subnet-2c"
  }
}

resource "aws_subnet" "aws20-private-subnet-2a" {
  vpc_id            = aws_vpc.aws20-vpc.id
  cidr_block        = var.private_subnet[0]
  availability_zone = var.azs[0]

  tags = {
    Name = "aws20-private-subnet-2a"
  }
}

resource "aws_subnet" "aws20-private-subnet-2c" {
  vpc_id            = aws_vpc.aws20-vpc.id
  cidr_block        = var.private_subnet[1]
  availability_zone = var.azs[1]

  tags = {
    Name = "aws20-private-subnet-2c"
  }
}

# 인터넷 게이트웨이
resource "aws_internet_gateway" "aws20-igw" {
  vpc_id = aws_vpc.aws20-vpc.id

  tags = {
    Name = "aws20-igw"
  }
}

#Elastic IP
resource "aws_eip" "aws20-eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.aws20-igw]
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "aws20-eip"
  }
}

#NAT G/W
resource "aws_nat_gateway" "aws20-nat" {
  allocation_id = aws_eip.aws20-eip.id
  subnet_id     = aws_subnet.aws20-public-subnet-2a.id
  depends_on    = [aws_internet_gateway.aws20-igw]

  tags = {
    Name = "aws20-nat"
  }
}


# default 라우팅 테이블 추가(편집)  *default = public (local은 VPC 생성 시 자동으로 만들어져 있음)
resource "aws_default_route_table" "aws20-public-rt-table" {
    default_route_table_id = aws_vpc.aws20-vpc.default_route_table_id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.aws20-igw.id
    }

    tags = {
        Name = "aws20-public-rt-table"
    }
}

# 명시적 서브넷 연결
resource "aws_route_table_association" "aws20-public-rt-2a" {
    subnet_id = aws_subnet.aws20-public-subnet-2a.id
    route_table_id = aws_default_route_table.aws20-public-rt-table.id
}

resource "aws_route_table_association" "aws20-public-rt-2c" {
    subnet_id = aws_subnet.aws20-public-subnet-2c.id
    route_table_id = aws_default_route_table.aws20-public-rt-table.id
}


# private route table
resource "aws_route_table" "aws20-private-rt-table" {
    vpc_id = aws_vpc.aws20-vpc.id
    tags = {
        Name = "aws20-private-rt-table"
    }
}


# private route 생성
resource "aws_route" "aws20-private-rt" {
    route_table_id = aws_route_table.aws20-private-rt-table.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aws20-nat.id
}

resource "aws_route_table_association" "aws20-private-rt-2a" {
    subnet_id = aws_subnet.aws20-private-subnet-2a.id
    route_table_id = aws_route_table.aws20-private-rt-table.id
}

resource "aws_route_table_association" "aws20-private-rt-2c" {
    subnet_id = aws_subnet.aws20-private-subnet-2c.id
    route_table_id = aws_route_table.aws20-private-rt-table.id
}