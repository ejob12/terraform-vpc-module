# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = var.vpc_name })
}

# Create Public Subnets
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.vpc_name}-public-subnet-${count.index + 1}" })
}

# Create Private Subnets
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags              = merge(var.tags, { Name = "${var.vpc_name}-private-subnet-${count.index + 1}" })
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { Name = "${var.vpc_name}-igw" })
}

# Create Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { Name = "${var.vpc_name}-public-rt" })
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_subnet_associations" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Add Default Route to Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Create NAT Gateway (Optional)
#resource "aws_eip" "nat_eip" {
 # count = var.enable_nat_gateway ? 1 : 0
 # tags  = merge(var.tags, { Name = "${var.vpc_name}-nat-eip" })
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags          = merge(var.tags, { Name = "${var.vpc_name}-nat-gw" })
}

# Create Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(var.tags, { Name = "${var.vpc_name}-private-rt" })
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_subnet_associations" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# Add Default Route to NAT Gateway (Optional)
#resource "aws_route" "private_nat_gateway" {
 # count                  = var.enable_nat_gateway ? 1 : 0
 # route_table_id         = aws_route_table.private_route_table.id
 # destination_cidr_block = "0.0.0.0/0"
 # nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}