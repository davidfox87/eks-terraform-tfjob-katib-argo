# to understand the special tags in subnets and vpc see
# https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
     "Name"                                       = "devops-test",
     "kubernetes.io/cluster/${var.cluster-name}"  = "shared",
    }

}

data "aws_availability_zones" "available" {
all_availability_zones = true
}

resource "aws_subnet" "public" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.vpc.id}"

  tags = {
     "Name"= "devops-test",
     "kubernetes.io/cluster/${var.cluster-name}"= "shared",
     "kubernetes.io/role/elb" = "1" # This is so that Kubernetes knows to use only the subnets that were specified for external load balancers.
  }
}

resource "aws_subnet" "private" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index+2}.0/24" # start the private subnet addresses right after the public ones
  vpc_id            = "${aws_vpc.vpc.id}"

  tags = {
     "Name"                                      = "devops-test",
     "kubernetes.io/cluster/${var.cluster-name}"  = "shared",
    }

}


resource "aws_internet_gateway" "mygateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "devops-test"
  }
}

resource "aws_route_table" "my_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mygateway.id
  }

}
resource "aws_route_table_association" "rta_subnet_public" {
  count = 2
  subnet_id      = aws_subnet.public[count.index].id

  route_table_id = aws_route_table.my_table.id
}


# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
}

# NAT gateway sits in first public subnet
resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = "${aws_subnet.public.*.id[0]}"

  tags = {
    Name        = "nat gw"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "my_nat_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

}
resource "aws_route_table_association" "rta_subnet_private" {
  count = 2
  subnet_id      = "${aws_subnet.private.*.id[count.index]}"
  route_table_id = aws_route_table.my_nat_table.id
}
