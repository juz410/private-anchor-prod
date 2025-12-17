output "external_alb_arn" {
  value = aws_lb.internal_alb.arn

}

output "alb_arn_suffix" {
  value = aws_lb.internal_alb.arn_suffix
}

output "name" {
  value = aws_lb.internal_alb.name
}
