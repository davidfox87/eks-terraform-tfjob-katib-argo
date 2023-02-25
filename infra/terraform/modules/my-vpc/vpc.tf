
# to understand the special tags in subnets and vpc see
# https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
resource "aws_vpc" "vpc" {
  cidr_block            = var.cidr
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags = {
     "Name"  = var.name,
  }
}


resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = element(var.public_subnets, count.index)
  availability_zone               = element(var.azs, count.index)
  map_public_ip_on_launch         = true

  tags = merge(
    {
      Name = try(
        var.public_subnet_names[count.index],
        format("${var.name}-${var.public_subnet_suffix}-%s", element(var.azs, count.index))
      )
    },
    var.public_subnet_tags,
  )
}


resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = element(var.private_subnets, count.index)
  availability_zone               = element(var.azs, count.index)
  map_public_ip_on_launch         = false

  tags = merge(
    {
      Name = try(
        var.private_subnet_names[count.index],
        format("${var.name}-${var.private_subnet_suffix}-%s", element(var.azs, count.index))
      )
    },
    var.private_subnet_tags,
  )
}


resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.vpc.id

  tags = { 
      "Name" = var.name 
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = { 
    "Name" = "${var.name}-${var.public_subnet_suffix}" 
  }
}

resource "aws_route" "public_internet_gateway" {
  count = length(var.public_subnets)

  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}










# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  tags = { 
      "Name" = var.name 
  }
}

# NAT gateway sits in first public subnet
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = "${aws_subnet.public.*.id[0]}"

  tags = { 
      "Name" = var.name 
  }
  depends_on = [
      aws_internet_gateway.this
  ]
}

resource "aws_route" "private_nat_gateway" {

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id

  timeouts {
    create = "5m"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = { 
    "Name" = "${var.name}-${var.private_subnet_suffix}" 
  }
}



resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


