#vpc
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.resource_name_prefix}-hk-vpc" })
}



# TGW attachment subnets
resource "aws_subnet" "private_dra_subnet_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_dra_subnet_a_cidr
  availability_zone = var.availability_zones[0]
  tags              = merge(var.tags, { Name = "${var.resource_name_prefix}-private-hk-dra-subnet-a" })
}

resource "aws_subnet" "private_dra_subnet_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_dra_subnet_b_cidr
  availability_zone = var.availability_zones[1]
  tags              = merge(var.tags, { Name = "${var.resource_name_prefix}-private-hk-dra-subnet-b" })
}


resource "aws_subnet" "private_tgw_subnet_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_tgw_subnet_a_cidr
  availability_zone = var.availability_zones[0]
  tags              = merge(var.tags, { Name = "${var.resource_name_prefix}-private-hk-tgw-subnet-a" })
}

resource "aws_subnet" "private_tgw_subnet_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_tgw_subnet_b_cidr
  availability_zone = var.availability_zones[1]
  tags              = merge(var.tags, { Name = "${var.resource_name_prefix}-private-hk-tgw-subnet-b" })
}




#private routes
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = var.tgw_id
    # nat_gateway_id = aws_nat_gateway.nat.id
  }
  #TODO: Add 0.0.0.0 to attachment after testing is done
  #   route {
  #     cidr_block = "0.0.0.0/0"
  #     transit_gateway_id = data.aws_ec2_transit_gateway.shared-tgw.id
  #   }
  tags = merge(var.tags, { Name = "${var.resource_name_prefix}-private-hk-route-table" })
}

resource "aws_route_table_association" "private_route_association" {
  for_each = {
    private_dra_subnet_a = aws_subnet.private_dra_subnet_a.id
    private_dra_subnet_b = aws_subnet.private_dra_subnet_b.id
    private_tgw_subnet_a = aws_subnet.private_tgw_subnet_a.id
    private_tgw_subnet_b = aws_subnet.private_tgw_subnet_b.id
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.private_route_table.id
}


#tgw
data "aws_ec2_transit_gateway" "shared-tgw" {
  id = var.tgw_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_ab" {
  subnet_ids         = [aws_subnet.private_tgw_subnet_a.id, aws_subnet.private_tgw_subnet_b.id]
  transit_gateway_id = data.aws_ec2_transit_gateway.shared-tgw.id
  vpc_id             = aws_vpc.main_vpc.id
  tags               = merge(var.tags, { Name = "${var.resource_name_prefix}-tgwa-hk-ab" })
}
