resource "aws_vpc" "aurora_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "aurora_vpc"
  }
}

resource "aws_internet_gateway" "aurora_internet_gateway" {
  vpc_id = aws_vpc.aurora_vpc.id
}

resource "aws_subnet" "aurora_vpc_subnet1" {
  vpc_id            = aws_vpc.aurora_vpc.id
  availability_zone = "ap-northeast-1a"
  cidr_block        = "10.0.1.0/24"
}

resource "aws_subnet" "aurora_vpc_subnet2" {
  vpc_id            = aws_vpc.aurora_vpc.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.0.2.0/24"
}

# Elastic IP
# https://www.terraform.io/docs/providers/aws/r/eip.html
resource "aws_eip" "aurora_nat_eip_1a" {
  vpc = true
}

resource "aws_eip" "aurora_nat_eip_1c" {
  vpc = true
}

# NAT Gateway
# https://www.terraform.io/docs/providers/aws/r/nat_gateway.html
resource "aws_nat_gateway" "aurora_nat_1a" {
  subnet_id     = aws_subnet.aurora_vpc_subnet1.id
  allocation_id = aws_eip.aurora_nat_eip_1a.id
}

resource "aws_nat_gateway" "aurora_nat_1c" {
  subnet_id     = aws_subnet.aurora_vpc_subnet2.id
  allocation_id = aws_eip.aurora_nat_eip_1c.id
}

resource "aws_db_subnet_group" "aurora_db_subnet_group" {
  name       = "aurora_db_subnet"
  subnet_ids = [
    aws_subnet.aurora_vpc_subnet1.id,
    aws_subnet.aurora_vpc_subnet2.id,
  ]
}

# Route Table
# https://www.terraform.io/docs/providers/aws/r/route_table.html
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.aurora_vpc.id
}

# Route
# https://www.terraform.io/docs/providers/aws/r/route.html
resource "aws_route" "aurora_public" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.aurora_internet_gateway.id
}

# Association
# https://www.terraform.io/docs/providers/aws/r/route_table_association.html
resource "aws_route_table_association" "aurora_public_1a" {
  subnet_id      = aws_subnet.aurora_vpc_subnet1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "aurora_public_1c" {
  subnet_id      = aws_subnet.aurora_vpc_subnet2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "aurora_sg" {
  name        = "aurora-security-group"
  description = "Security group for Aurora MySQL instance"
  vpc_id      = aws_vpc.aurora_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # EXPOSED TO ALL IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # EXPOSED TO ALL IP
  }
}
