resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-${var.vpc_name}"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.environment}-public-${each.key}"
    Tier                                        = "public"
    # CRITICAL SHOWCASE TAGS FOR KUBERNETES LOAD BALANCERS
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_subnet" "private_app_subnets" {
  for_each                = var.private_app_subnets
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name                                        = "${var.environment}-private-${each.key}"
    Tier                                        = "private"
    # CRITICAL SHOWCASE TAGS FOR KUBERNETES INTERNAL LOAD BALANCERS
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.environment}-igw" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "${var.environment}-public-rt" }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table" "private_rt" {
  for_each = var.private_app_subnets
  vpc_id   = aws_vpc.main.id
  tags     = { Name = "${var.environment}-private-rt-${each.key}" }
}

resource "aws_route" "private_nat_access" {
  for_each               = var.private_app_subnets
  route_table_id         = aws_route_table.private_rt[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[each.key].id
}

resource "aws_route_table_association" "public_rt_association" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_association" {
  for_each       = var.private_app_subnets
  subnet_id      = aws_subnet.private_app_subnets[each.key].id
  route_table_id = aws_route_table.private_rt[each.key].id
}

resource "aws_eip" "nat" {
  for_each = var.public_subnets
  domain   = "vpc"
  tags     = { Name = "${var.environment}-nat-eip-${each.key}" }
}

resource "aws_nat_gateway" "ngw" {
  for_each      = var.public_subnets
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public_subnets[each.key].id
  depends_on    = [aws_internet_gateway.igw]
  tags          = { Name = "${var.environment}-nat-gw-${each.key}" }
}