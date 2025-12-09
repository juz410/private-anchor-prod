output "db_endpoints" {
  value = aws_db_instance.rds.endpoint
}

output "db_identifier" {
  value = aws_db_instance.rds.identifier
}

output "name" {
  value = var.name
}
