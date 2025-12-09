output "storage_alarm_arns" {
  value = { for k, v in aws_cloudwatch_metric_alarm.storage_left_gb : k => v.arn }
}

#anchor extra
# output "cpu_alarm_arns" {
#   value = { for k, v in aws_cloudwatch_metric_alarm.cpu : k => v.arn }
# }

# output "connection_alarm_arns" {
#   value = { for k, v in aws_cloudwatch_metric_alarm.connections : k => v.arn }
# }


