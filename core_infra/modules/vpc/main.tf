
# Create a new VPC and use for your workload
# Do not use the default VPC and ensure that it is deleted from your account

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true   # Enable DNS support
  enable_dns_hostnames = true # Enable DNS hostnames for instances
  tags = local.vpc_tags
}

# Create Public Subnet
resource "aws_subnet" "private" {
  count = 3

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.public_subnet_cidr, 2, count.index)
  availability_zone = element(["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"], count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index}"
  }
}

# Create Private Subnet
resource "aws_subnet" "private" {
  count = 3

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(var.private_subnet_cidr, 2, count.index)
  availability_zone = element(["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"], count.index)
  tags = {
    Name = "private-subnet-${count.index}"
  }
}

# Internet Gateway for Public Subnet
# This should be replaced by Proxy Server
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
      var.tags, 
      {Name = "Internet Gateway"}
    )
}


# Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(
      var.tags,
      { Name = "Public Route Table" }
    )
}

# Route Table Associations for Public Subnet
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_route_table.id
}



# Route Table Associations for Private Subnet
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_route_table.id
}


# NAT Gateway for Private Subnet (Optional)
# This should be replaced with Proxy Server to enable internet egress traffic
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = merge(
      var.tags,
      { Name = "NAT Gateway" }
    )
}

resource "aws_eip" "nat" {
  domain = vpc
}

# Route Table for Private Subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(
      var.tags,
      { Name = "Private Route Table" }
    )
}

