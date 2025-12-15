output "ec2_instance_id" {
  value = aws_instance.this.id
}

output "instance_type" {
  value = aws_instance.this.instance_type
}
output "name" {
  value = aws_instance.this.tags["Name"]
}

output "arn" {
  value = aws_instance.this.arn
}