output "rule_arn" {
  value = try(aws_cloudwatch_event_rule.ec2_state_change[0].arn, null)
}

output "rule_name" {
  value = try(aws_cloudwatch_event_rule.ec2_state_change[0].name, null)
}
