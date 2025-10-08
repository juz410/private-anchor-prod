resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.name
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, { Name = var.name })

}