#######
# VPC #
#######

resource "aws_vpc" "project_8" {
  cidr_block           = var.cidr_vpc
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-${var.name}"
  }
}


###########
# Subnets #
###########

resource "aws_subnet" "subnets" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }

  vpc_id                  = aws_vpc.project_8.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name = each.value.name
  }
}


####################
# Internet Gateway #
####################

resource "aws_internet_gateway" "igw_p8" {
  vpc_id = aws_vpc.project_8.id

  tags = {
    Name = "igw-${var.name}"
  }
}


###########################################
# Route table and route table association #
###########################################

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.project_8.id
  route {
    cidr_block = var.internet-cidr
    gateway_id = aws_internet_gateway.igw_p8.id
  }
}

resource "aws_route_table_association" "rt_association" {
  for_each = aws_subnet.subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.rt.id
}


##################
# Security Group #
##################

resource "aws_security_group" "p8_sg" {
  vpc_id = aws_vpc.project_8.id
  name   = "${var.name}-security-group"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.internet-cidr]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.internet-cidr]
  }

  ingress {
    from_port   = "2049"
    to_port     = "2049"
    protocol    = "tcp"
    cidr_blocks = [var.internet-cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.internet-cidr]
  }

  tags = {
    Name = "sg-${var.name}"
  }
}
