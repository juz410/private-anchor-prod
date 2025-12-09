output "alarm_arns" {
  value = merge(
    { for k, v in aws_cloudwatch_metric_alarm.cpu : k => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.memory : k => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.statuscheck_either : k => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.disk_low_percent_free : k => v.arn },
    { for k, v in aws_cloudwatch_metric_alarm.disk_left_gb : k => v.arn }
  )
}
