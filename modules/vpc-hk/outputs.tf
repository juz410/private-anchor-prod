
output "private_route_table_id" {
  value = aws_route_table.private_route_table.id
}

output "main_vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "main_vpc_name" {
  value = aws_vpc.main_vpc.tags_all["Name"]
}


output "private_dra_subnet_a_id" {
  value = aws_subnet.private_dra_subnet_a.id
}

output "private_dra_subnet_b_id" {
  value = aws_subnet.private_dra_subnet_b.id
}


output "private_tgw_subnet_a_id" {
  value = aws_subnet.private_tgw_subnet_a.id
}

output "private_tgw_subnet_b_id" {
  value = aws_subnet.private_tgw_subnet_b.id
}


output "tgw_attachment_ab_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_ab.id
}

