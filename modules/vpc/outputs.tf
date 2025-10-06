output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "public_route_table_id" {
  value = aws_route_table.public_route_table.id
}
output "private_route_table_id" {
  value = aws_route_table.private_route_table.id
}

output "main_vpc_id" {
  value = aws_vpc.main_vpc.id
}

# Public subnets
output "public_subnet_a_id" {
  value = aws_subnet.public_subnet_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_subnet_b.id
}

# Kalsym App subnets
output "private_kalsym_app_subnet_a_id" {
  value = aws_subnet.private_kalsym_app_subnet_a.id
}

output "private_kalsym_app_subnet_b_id" {
  value = aws_subnet.private_kalsym_app_subnet_b.id
}

# Kalsym ECS subnets
output "private_kalsym_ecs_subnet_a_id" {
  value = aws_subnet.private_kalsym_ecs_subnet_a.id
}

output "private_kalsym_ecs_subnet_b_id" {
  value = aws_subnet.private_kalsym_ecs_subnet_b.id
}

# Kalsym DB subnets
output "private_kalsym_db_subnet_a_id" {
  value = aws_subnet.private_kalsym_db_subnet_a.id
}

output "private_kalsym_db_subnet_b_id" {
  value = aws_subnet.private_kalsym_db_subnet_b.id
}

# Internal ALB subnets
output "private_internal_alb_subnet_a_id" {
  value = aws_subnet.private_internal_alb_subnet_a.id
}

output "private_internal_alb_subnet_b_id" {
  value = aws_subnet.private_internal_alb_subnet_b.id
}

# Multibyte App subnets
output "private_multibyte_subnet_a_id" {
  value = aws_subnet.private_multibyte_subnet_a.id
}

output "private_multibyte_subnet_b_id" {
  value = aws_subnet.private_multibyte_subnet_b.id
}

# Multibyte DB subnets
output "private_multibyte_db_subnet_a_id" {
  value = aws_subnet.private_multibyte_db_subnet_a.id
}

output "private_multibyte_db_subnet_b_id" {
  value = aws_subnet.private_multibyte_db_subnet_b.id
}

# TGW subnets
output "private_tgw_subnet_a_id" {
  value = aws_subnet.private_tgw_subnet_a.id
}

output "private_tgw_subnet_b_id" {
  value = aws_subnet.private_tgw_subnet_b.id
}


output "tgw_attachment_ab_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment_ab.id
}

