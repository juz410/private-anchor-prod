# modules/nlb/outputs.tf
output "nlb_arn_suffix" {
  value = aws_lb.external_nlb.arn_suffix
}

output "nlb_name" {
  value = aws_lb.external_nlb.name
}