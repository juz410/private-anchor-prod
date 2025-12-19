locals {
  event_bus_name = coalesce(var.event_bus_name, "default")

  # Merge mandatory state filter with optional instance-id filter
  event_detail_filter = merge(
    {
      state = var.ec2_state_values
    },
    length(var.instance_ids) == 0 ? {} : { "instance-id" = var.instance_ids }
  )

  create_rule = var.enable_when_no_instances || length(var.instance_ids) > 0
}

resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  count = local.create_rule ? 1 : 0

  name           = substr("${var.resource_name_prefix}-ec2-state-change", 0, 64)
  description    = "EC2 instance state change notifications"
  event_bus_name = local.event_bus_name
  event_pattern = jsonencode({
    "source"      : ["aws.ec2"],
    "detail-type" : ["EC2 Instance State-change Notification"],
    "detail"      : local.event_detail_filter
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "lambda" {
  count = local.create_rule ? 1 : 0

  rule           = aws_cloudwatch_event_rule.ec2_state_change[count.index].name
  target_id      = "lambda-ec2-state-publisher"
  arn            = var.lambda_function_arn
  event_bus_name = local.event_bus_name
}

resource "aws_lambda_permission" "allow_eventbridge" {
  count = local.create_rule ? 1 : 0

  statement_id  = "AllowExecutionFromEvents-ec2-state-change"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_state_change[count.index].arn
}
