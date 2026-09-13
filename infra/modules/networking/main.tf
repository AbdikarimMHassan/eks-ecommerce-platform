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
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
    "karpenter.sh/discovery"                    = var.cluster_name
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

resource "aws_route_table_association" "public_rt_association" {
  for_each       = var.public_subnets
  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_rt" {
  for_each = var.private_app_subnets
  vpc_id   = aws_vpc.main.id
  tags     = { Name = "${var.environment}-private-rt-${each.key}" }
}

resource "aws_route_table_association" "private_rt_association" {
  for_each       = var.private_app_subnets
  subnet_id      = aws_subnet.private_app_subnets[each.key].id
  route_table_id = aws_route_table.private_rt[each.key].id
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.environment}-vpc-endpoints-sg"
  description = "Allow HTTPS from private subnets to AWS service Interface endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTPS from private subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [for subnet in aws_subnet.private_app_subnets : subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.environment}-vpc-endpoints-sg" }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for rt in aws_route_table.private_rt : rt.id]

  tags = { Name = "${var.environment}-s3-endpoint" }
}

locals {
  interface_endpoints = {
    ecr_api        = "com.amazonaws.${var.region}.ecr.api"
    ecr_dkr        = "com.amazonaws.${var.region}.ecr.dkr"
    secretsmanager = "com.amazonaws.${var.region}.secretsmanager"
    sqs            = "com.amazonaws.${var.region}.sqs"
    sts            = "com.amazonaws.${var.region}.sts"
    logs           = "com.amazonaws.${var.region}.logs"
    monitoring     = "com.amazonaws.${var.region}.monitoring"
  }
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each = local.interface_endpoints

  vpc_id              = aws_vpc.main.id
  service_name        = each.value
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for subnet in aws_subnet.private_app_subnets : subnet.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = { Name = "${var.environment}-${each.key}-endpoint" }
}