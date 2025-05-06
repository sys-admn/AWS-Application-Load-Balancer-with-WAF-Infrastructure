resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Name = "${var.tag}-vpc"
      NetworkTier = "Core"
      ResourceType = "VPC"
    },
    var.tags
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.tag}-igw"
      NetworkTier = "Public"
      ResourceType = "InternetGateway"
    },
    var.tags
  )
}

resource "aws_subnet" "public" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  map_public_ip_on_launch = var.associate_public_ip_address
  availability_zone       = element(var.availability_zones, count.index)

  tags = merge(
    {
      Name = "${var.tag}-public-subnet-${count.index + 1}"
      NetworkTier = "Public"
      ResourceType = "Subnet"
      SubnetType = "Public"
      AvailabilityZone = element(var.availability_zones, count.index)
    },
    var.tags
  )
}

resource "aws_subnet" "private" {
  count             = var.private_subnet_count == 0 ? var.public_subnet_count : var.private_subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr_block, 8, count.index + var.public_subnet_count)
  availability_zone = element(var.availability_zones, count.index)

  tags = merge(
    {
      Name = "${var.tag}-private-subnet-${count.index + 1}"
      NetworkTier = "Private"
      ResourceType = "Subnet"
      SubnetType = "Private"
      AvailabilityZone = element(var.availability_zones, count.index)
    },
    var.tags
  )
}

resource "aws_eip" "nat" {
  count  = var.create_nat_gateway ? (var.single_nat_gateway ? 1 : var.public_subnet_count) : 0
  domain = "vpc"

  tags = merge(
    {
      Name = "${var.tag}-eip-${count.index + 1}"
      ResourceType = "ElasticIP"
      Purpose = "NAT"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  count         = var.create_nat_gateway ? (var.single_nat_gateway ? 1 : var.public_subnet_count) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name = "${var.tag}-nat-gateway-${count.index + 1}"
      NetworkTier = "Public"
      ResourceType = "NATGateway"
      Purpose = "PrivateSubnetInternetAccess"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      Name = "${var.tag}-public-route-table"
      NetworkTier = "Public"
      ResourceType = "RouteTable"
      Purpose = "PublicSubnetRouting"
    },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = var.create_nat_gateway ? (var.single_nat_gateway ? 1 : var.public_subnet_count) : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.nat[0].id : aws_nat_gateway.nat[count.index].id
  }

  tags = merge(
    {
      Name = "${var.tag}-private-route-table${var.single_nat_gateway ? "" : "-${count.index + 1}"}"
      NetworkTier = "Private"
      ResourceType = "RouteTable"
      Purpose = "PrivateSubnetRouting"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private" {
  count          = var.create_nat_gateway ? length(aws_subnet.private) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.single_nat_gateway ? aws_route_table.private[0].id : aws_route_table.private[min(count.index, length(aws_route_table.private) - 1)].id
}